local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'

local Vector = {}
Vector.__index = Vector

setmetatable(Vector, {
        __call = function (cls, ...)
            return cls.new(...)
        end,
    })

local original_type = type  -- saves `type` function
-- monkey patch type function
type = function( obj )
  local otype = original_type( obj )
  if  otype == "table" and getmetatable( obj ) == Vector then
    return "Vector"
  end
  return otype
end

local function materialized_vec(self, arg) 

  assert(self.file_name == nil)
  self.file_name = assert(arg.file_name, "file_name not specified for read")

  --mmap the file
  local is_write = true
  if ( ( arg.is_write ) and ( arg.is_write == false ) ) then 
    is_write = false
  end
  self.mmap = assert(ffi.gc(qc.f_mmap(self.file_name, is_write), 
    qc.f_munmap))
  self.mmap = ffi.cast("MMAP_REC_TYPE *", self.mmap)
  self.is_write = is_write

  self.num_elements = tonumber(self.map_len) / self.field_size
  assert(self.num_elements > 0 )
  assert(math.ceil(self.num_elements)  == self.num_elements)
  assert(math.floor(self.num_elements) == self.num_elements)

  if ( qconsts.debug ) then self:check() end
  return self
end

local function nascent_vec(self)
  local sz = qconsts.chunk_size * self.field_size
  self.chunk = ffi.new("char[?]", sz)
  assert(self.chunk)
  ffi.fill(self.chunk, sz)

  self.chunk_num    = 0
  self.num_in_chunk = 0
  self.num_elements = 0
  self.is_memo = true
  sz = qconsts.max_len_file_name+1
  self.file_name = ffi.new("char[?]", sz)
  assert(self.file_name)
  ffi.fill(self.file_name, sz)
  qc['rand_file_name'](self.file_name, qconsts.max_len_file_name)
  if ( qconsts.debug ) then self:check() end
  return self
end

function Vector:check()
  --[==[

  --================================================
  assert(self.field_type)
  assert(type(self.field_type) == "string")
  if ( self.field_type ~= "SC" ) then 
    assert(self.field_size == qconsts.qtypes[self.field_type].width)
  else
    assert(self.field_size >= 2)
  end
  --================================================
  if ( self.is_nascent ) then
    assert(self.chunk)

    assert(self.chunk_num)
    assert(type(self.chunk_num) == "number")
    assert(self.chunk_num >= 0 )

    assert(self.num_in_chunk)
    assert(type(self.num_in_chunk) == "number")
    assert(self.num_in_chunk >= 0 )

    if ( self.is_memo ) then
      assert(self.file_name)
    else
      assert(self.file_name == nil)
    end
    assert(self.is_write == nil)
    assert(((self.chunk_num * qconsts.chunk_size) + self.num_in_chunk)
      == self.num_elements)
      --[[
    if ( ( self.chunk_num >= 1 ) and ( self.is_memo ) ) then 
      assert(self.file_name)
      assert(plpath.isfile(ffi.string(self.file_name)))
      local file_size = (self.chunk_num*self.field_size*qconsts.chunk_size)
      assert(file_size == plpath.getsize(ffi.string(self.file_name)))
    end
    --]]
  else
    if ( self.is_write ) then 
      assert(type(self.is_write) == "boolean")
    end
    assert(self.chunk == nil)
    assert(self.num_in_chunk == nil)
    assert(self.chunk_num == nil)
  --================================================
    local mmap = assert(ffi.cast("MMAP_REC_TYPE *", self.mmap))
    local file_name  = assert(mmap[0].file_name)
    local map_addr   = assert(mmap[0].map_addr)
    local is_persist = assert(mmap[0].is_persist)
    local map_len    = assert(mmap[0].map_len)

    file_name = ffi.string(file_name)

    assert((is_persist == 0 ) or ( is_persist == 1))
    assert(map_len > 0)
    local file_size = qc['get_file_size'](self.file_name)
    assert(file_size > 0)

    local chk_len = tonumber(file_size) / self.field_size
    assert(math.ceil(chk_len) == self.num_elements)
    assert(math.floor(chk_len) == self.num_elements)
    assert(self.num_elements > 0)
  --================================================
  end
  --]==]

  return true
end

function Vector.new(arg)
  local vec = setmetatable({}, Vector)

  -- set qtype
  assert(type(arg) == "table", "argument to constructor should be table")
  local qtype = assert(arg.field_type, "must specifyt fldtype for vector")
  assert(type(qtype) == "string")
  assert(qconsts.qtypes[qtype], "Valid qtype not given")
  vec.field_type = qtype

  -- set field_size
  if ( qtype == "SC" ) then 
    local fldsz = assert(arg.field_size, "Must specify field size for SC")
    assert(type(fldsz) == "number")
    assert(fldsz >= 2, "Field size must be >= 2 (one for nullc)")
    vec.field_size = fldsz
  else
    assert(arg.field_size == nil, "Can specify field size only for SC")
    vec.field_size = qconsts.qtypes[qtype].width
  end
  --====== is vector materialized or nascent
  assert(arg.is_nascent)
  assert(type(arg.is_nascent) == "boolean")
  vec.is_nascent = arg.is_nascent
  if arg.is_nascent then 
    vec = assert(nascent_vec(vec))
  else
    vec = assert(materialized_vec(vec, arg))
  end
  return vec
end

function Vector:length()
  if ( qconsts.debug ) then self:check() end
  return self.num_elements
end

function Vector:fldtype()
  if ( qconsts.debug ) then self:check() end
  return self.field_type
end

function Vector:sz()
  if ( qconsts.debug ) then self:check() end
  return self.field_size
end

function Vector:memo(is_memo)
  print(is_memo)
  assert(type(is_memo) == "boolean", "Incorrect type supplied")
  if ( self.is_nascent ) then 
    if ( self.chunk_num > 0 ) then 
      assert(nil, "Too late to set memo")
    end
    if ( is_memo == self.is_memo ) then
      return -- No change made
    end
    if ( is_memo ) then 
      self.is_memo = true
      if ( not self.file_name ) then 
        sz = qconsts.max_len_file_name+1
        self.file_name = ffi.new("char [?]", sz)
        assert(self.file_name)
        ffi.fill(self.file_name, sz)
        qc['rand_file_name'](self.file_name, qconsts.max_len_file_name)
      end
    else
      self.is_memo = false
      self.file_name = nil
    end
  else
    -- change to log 
    print("No need to memo when materialized")
  end
  if ( qconsts.debug ) then self:check() end
end

function Vector:is_memo()
  if ( qconsts.debug ) then self:check() end
  return self.is_memo
end

function Vector:set(addr, idx, len)
  assert(addr)
  assert(len)
  assert(type(len) == "number")
  assert(len >= 1)
  if ( self.is_nascent ) then
    -- have to start writing from where you left off
    assert( idx == nil)
    local initial_num_elements = self.num_elements
    -- TODO < or <= ?
    -- if ( (len + num_in_chunk) < qconsts.chunk_size ) then
    local num_left_to_copy = len
    repeat 
      local space_in_chunk = qconsts.chunk_size - self.num_in_chunk
      if ( space_in_chunk == 0 )  then
        if ( self.is_memo ) then
          print(self.chunk)
          local use_c_code = false
          if ( use_c_code ) then 
            print("C: Writing to file")
            local status = qc["buf_to_file"](self.chunk,
            self.field_size, self.num_in_chunk, self.file_name)
            print("C: Done with file")
          else 
            local fp = ffi.C.fopen(ffi.string(self.file_name), "a")
            print("L: Opened file")
            local nw = ffi.C.fwrite(self.chunk, qconsts.chunk_size,
              self.field_size, fp);
            print("L: Wrote to file")
            -- assert(nw > 0 )
            ffi.C.fclose(fp)
            print("L: Done with file")
          end
        end
        self.num_in_chunk = 0
        self.chunk_num = self.chunk_num + 1
        space_in_chunk = qconsts.chunk_size
        ffi.fill(self.chunk, qconsts.chunk_size * self.field_size, 0)
      end

      local num_to_copy  = len
      if ( space_in_chunk < len ) then 
        num_to_copy = space_in_chunk
      end
      -- local num_to_copy = min(len, space_in_chunk)
      local dst = ffi.cast("char *", self.chunk) + 
        (self.num_in_chunk * self.field_size)
      ffi.copy(dst, addr, num_to_copy * self.field_size)
      num_left_to_copy = num_left_to_copy - num_to_copy
      addr = ffi.cast("char *", addr) + (num_to_copy * self.field_size)
      self.num_in_chunk = self.num_in_chunk + num_to_copy
      self.num_elements = self.num_elements + num_to_copy
    until num_left_to_copy == 0
    assert(self.num_elements == initial_num_elements + len)
  else
    assert(self.is_write == true)
    assert(idx)
    assert(type(idx) == "number")
    assert(idx >= 0)
    assert(self.mmap)
    assert(idx < self.num_elements)
    assert(idx+len < self.num_elements)
    local dst = self.mmap.map_addr + (idx * self.field_size)
    local n = len * self.field_size
    ffi.copy(dst, addr, n)
  end
  -- if ( qconsts.debug ) then self:check() end
end

function Vector:get(idx, len)
  local addr

  assert(idx)
  assert(type(idx) == "number")
  assert(idx >= 0)

  assert(len)
  assert(type(len) == "number")
  assert(len >= 1)
  if ( self.is_nascent ) then 
    local chunk_num = math.floor(idx / qconsts.chunk_size)
    local chunk_idx = idx % qconsts.chunk_size
    assert(chunk_num == self.chunk_num)
    assert(num_in_chunk + len <= qconsts.chunk_size)
    addr = self.chunk + (chunk_idx * self.field_size)
  else
    assert(idx < self.num_elements)
    assert(idx+len <= self.num_elements)
    addr = ffi.cast("char *", self.mmap.map_addr) + (idx * self.field_size)
  end
  if ( qconsts.debug ) then self:check() end
  return addr
end

function Vector:eov()
  -- flush last chunk to file 
  assert(self.is_nascent)
  if ( self.num_in_chunk == 0 ) then return end
  local fp = ffi.C.fopen(ffi.string(self.file_name), "a")
  local nw = ffi.C.fwrite(self.chunk, self.num_in_chunk, self.field_size, fp);
  -- TODO Why does this not work? assert(nw == self.num_in_chunk)
  assert(nw > 0 )
  ffi.C.fclose(fp)
  -- open file for r/w access
  self.is_write = true
  self.mmap = assert(ffi.gc(qc.f_mmap(self.file_name, self.is_write), 
  qc.f_munmap))
  self.is_nascent = false
  -- destroy stuff not needed any more
  self.chunk = nil
  self.num_in_chunk = nil
  self.chunk_num = nil
  self.file_name = nil
  if ( qconsts.debug ) then self:check() end
end

function Vector:internals()
  if ( qconsts.debug ) then self:check() end
  return self -- TODO Check with IS for tostring() compatibility
end

function Vector:persist()
   -- TODO Add routine to materialize if not already materialized
  self.mmap.is_persist = true
  assert(self.is_nascent == false)
end


function Vector:meta()
  local T = {}
  if ( self.file_name ) then 
    T.file_name = self.file_name
  end
  if ( self.mmap ) then
    T.map_len = self.mmap.map_len
    T.file_name = self.mmap.file_name
    T.is_persist = self.mmap.is_persist
  end
  return T
end

return require('Q/q_export').export('Vector', Vector)
