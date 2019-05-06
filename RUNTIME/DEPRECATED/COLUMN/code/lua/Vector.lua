local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local qc      = require 'Q/UTILS/lua/q_core'
local log     = require 'Q/UTILS/lua/log'

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

  assert(self._file_name == nil)
  self._file_name = assert(arg.file_name, "file_name not specified for read")

  --mmap the file
  local is_write = true
  if ( ( arg.is_write ) and ( arg.is_write == false ) ) then 
    is_write = false
  end
  self._mmap = assert(ffi.gc(qc.f_mmap(self._file_name, is_write), 
    qc.f_munmap))
  self._mmap = ffi.cast("MMAP_REC_TYPE *", self._mmap)
  self._is_write = is_write

  self._num_elements = tonumber(self._mmap.map_len) / self._field_size
  assert(self._num_elements > 0 )
  assert(math.ceil(self._num_elements)  == self._num_elements)
  assert(math.floor(self._num_elements) == self._num_elements)

  if ( qconsts.debug ) then self:check() end
  return self
end

local function nascent_vec(self)
  local sz = qconsts.chunk_size * self._field_size
  -- self._chunk = ffi.new("char[?]", sz)
  self._chunk = ffi.malloc(sz, qc.c_free)
  assert(self._chunk)
  ffi.fill(self._chunk, sz)

  self._chunk_num    = 0
  self._num_in_chunk = 0
  self._num_elements = 0
  self._is_memo = true
  return self
end

function Vector:check()
  --================================================
  assert(self._field_type)
  assert(type(self._field_type) == "string")
  if ( self._field_type ~= "SC" ) then 
    assert(self._field_size == qconsts.qtypes[self._field_type].width)
  else
    assert(self._field_size >= 2)
  end
  --================================================
  if ( self._is_nascent) then 
    assert(self._chunk)

    assert(self._chunk_num)
    assert(type(self._chunk_num) == "number")
    assert(self._chunk_num >= 0 )

    assert(self._num_in_chunk)
    assert(type(self._num_in_chunk) == "number")
    assert(self._num_in_chunk >= 0 )

    assert(self._is_write == nil)
    assert(((self._chunk_num * qconsts.chunk_size) + self._num_in_chunk)
      == self._num_elements)
    if ( self._chunk_num >= 1 ) and ( self._is_memo ) then 
      assert(self._file_name)
      local actual_file_size = qc['get_file_size'](self._file_name)
      local expected_file_size = (self._chunk_num*self._field_size*qconsts.chunk_size)
      assert(actual_file_size == expected_file_size)
    end
  else
    if ( self._is_write ) then 
      assert(type(self._is_write) == "boolean")
    end
    assert(self._chunk == nil)
    assert(self._num_in_chunk == nil)
    assert(self._chunk_num == nil)
  --================================================
    local mmap = assert(ffi.cast("MMAP_REC_TYPE *", self._mmap))
    local file_name  = assert(mmap[0].file_name)
    local map_addr   = assert(mmap[0].map_addr)
    local is_persist = assert(mmap[0].is_persist)
    local map_len    = assert(mmap[0].map_len)

    file_name = ffi.string(file_name)

    assert((is_persist == 0 ) or ( is_persist == 1))
    assert(map_len > 0)
    local file_size = qc['get_file_size'](self._file_name)
    assert(file_size > 0)

    local chk_len = tonumber(file_size) / self._field_size
    assert(math.ceil(chk_len) == self._num_elements)
    assert(math.floor(chk_len) == self._num_elements)
    assert(self._num_elements > 0)
  --================================================
  end
  return true
end

function Vector.new(arg)
  local vec = setmetatable({}, Vector)

  -- set qtype
  assert(type(arg) == "table", "argument to constructor should be table")
  local qtype = assert(arg.field_type, "must specifyt fldtype for vector")
  assert(type(qtype) == "string")
  assert(qconsts.qtypes[qtype], "Valid qtype not given")
  vec._field_type = qtype

  -- set field_size
  if ( qtype == "SC" ) then 
    local fldsz = assert(arg.field_size, "Must specify field size for SC")
    assert(type(fldsz) == "number")
    assert(fldsz >= 2, "Field size must be >= 2 (one for nullc)")
    vec._field_size = fldsz
  else
    assert(arg.field_size == nil, "Can specify field size only for SC")
    vec._field_size = qconsts.qtypes[qtype].width
  end
  --====== is vector materialized or nascent
  assert(arg.is_nascent ~= nil)
  assert(type(arg.is_nascent) == "boolean")
  vec._is_nascent = arg.is_nascent
  if arg.is_nascent then 
    vec = assert(nascent_vec(vec))
  else
    vec = assert(materialized_vec(vec, arg))
  end
  return vec
end

function Vector:length()
  if ( qconsts.debug ) then self:check() end
  return self._num_elements
end

function Vector:fldtype()
  if ( qconsts.debug ) then self:check() end
  return self._field_type
end

function Vector:sz()
  if ( qconsts.debug ) then self:check() end
  return self._field_size
end

function Vector:is_memo()
  if ( qconsts.debug ) then self:check() end
  return self._is_memo
end

function Vector:internals()
  if ( qconsts.debug ) then self:check() end
  return self -- TODO Check with IS for tostring() compatibility
end

function Vector:memo(is_memo)
  print(is_memo)
  assert(type(is_memo) == "boolean", "Incorrect type supplied")
  if ( self._is_nascent ) then 
    if ( self._chunk_num > 0 ) then 
      assert(nil, "Too late to set memo")
    end
    if ( is_memo == self._is_memo ) then
      return -- No change made
    end
    if ( is_memo ) then 
      self._is_memo = true
      if ( not self._file_name ) then 
        sz = qconsts.max_len_file_name+1
        -- self._file_name = ffi.new("char [?]", sz)
        self._file_name = ffi.malloc(sz, qc.c_free)
        assert(self._file_name)
        ffi.fill(self._file_name, sz)
        qc['rand_file_name'](self._file_name, qconsts.max_len_file_name)
      end
    else
      self._is_memo = false
      self._file_name = nil
    end
  else
    log.warn("No need to memo when materialized")
  end
  if ( qconsts.debug ) then self:check() end
end

function Vector:set(addr, idx, len)
  assert(addr)
  assert(len)
  assert(type(len) == "number")
  assert(len >= 1)
  if ( self._is_nascent ) then
    -- have to start writing from where you left off
    assert( idx == nil)
    local initial_num_elements = self._num_elements
    -- TODO < or <= ?
    -- if ( (len + num_in_chunk) < qconsts.chunk_size ) then
    local num_left_to_copy = len
    repeat 
      local space_in_chunk = qconsts.chunk_size - self._num_in_chunk
      if ( space_in_chunk == 0 )  then
        if ( self._is_memo ) then
          if ( not self._file_name ) then 
            local sz = qconsts.max_len_file_name + 1
            -- self._file_name = ffi.new("char[?]", sz)
            self._file_name = ffi.malloc(sz, qc.c_free)
            assert(self._file_name)
            ffi.fill(self._file_name, sz)
            qc['rand_file_name'](self._file_name, qconsts.max_len_file_name)
          end
          local use_c_code = true
          if ( use_c_code ) then 
            local status = qc["buf_to_file"](self._chunk,
            self._field_size, self._num_in_chunk, self._file_name)
          else 
            local fp = ffi.C.fopen(self._file_name, "a")
            print("L: Opened file")
            local nw = ffi.C.fwrite(self._chunk, self._field_size, 
              qconsts.chunk_size, fp);
            print("L: Wrote to file")
            -- assert(nw > 0 )
            ffi.C.fclose(fp)
            print("L: Done with file")
          end
        end
        self._num_in_chunk = 0
        self._chunk_num = self._chunk_num + 1
        space_in_chunk = qconsts.chunk_size
        ffi.fill(self._chunk, qconsts.chunk_size * self._field_size, 0)
      end

      local num_to_copy  = len
      if ( space_in_chunk < len ) then 
        num_to_copy = space_in_chunk
      end
      qc["c_copy"](self._chunk, addr, self._num_in_chunk, num_to_copy, 
        self._field_size)
      --[[ Not sure why following does not work.
      local dst = ffi.cast("char *", self._chunk) 
        + (self._num_in_chunk * self._field_size)
      ffi.copy(dst, addr, num_to_copy * self._field_size)
      --]]

      num_left_to_copy = num_left_to_copy - num_to_copy
      self._num_in_chunk = self._num_in_chunk + num_to_copy
      self._num_elements = self._num_elements + num_to_copy
    until num_left_to_copy == 0
    assert(self._num_elements == initial_num_elements + len)
  else
    print(self._is_nascent)
    os.exit()
    assert(self._is_write == true)
    assert(idx)
    assert(type(idx) == "number")
    assert(idx >= 0)
    assert(self._mmap)
    assert(idx < self._num_elements)
    assert(idx+len < self._num_elements)
    local dst = self._mmap.map_addr + (idx * self._field_size)
    local n = len * self._field_size
    ffi.copy(dst, addr, n)
  end
   if ( qconsts.debug ) then self:check() end
end


function Vector:get(idx, len)
  local addr

  assert(idx)
  assert(type(idx) == "number")
  assert(idx >= 0)

  assert(len)
  assert(type(len) == "number")
  assert(len >= 1)
  if ( self._is_nascent ) then 
    local chunk_num = math.floor(idx / qconsts.chunk_size)
    local chunk_idx = idx % qconsts.chunk_size
    assert(chunk_num == self._chunk_num)
    assert(num_in_chunk + len <= qconsts.chunk_size)
    addr = self._chunk + (chunk_idx * self._field_size)
  else
    assert(idx < self._num_elements)
    assert(idx+len <= self._num_elements)
    addr = ffi.cast("char *", self._mmap.map_addr) + (idx * self._field_size)
  end
  if ( qconsts.debug ) then self:check() end
  return addr
end

function Vector:eov()
  -- flush last chunk to file 
  assert(self._is_nascent)
  if ( self._num_in_chunk == 0 ) then return end
  local status = qc["buf_to_file"](self._chunk,
            self._field_size, self._num_in_chunk, self._file_name)
  -- open file for r/w access
  self._is_write = true
  self._mmap = assert(ffi.gc(qc.f_mmap(self._file_name, self._is_write), 
  qc.f_munmap))
  self._is_nascent = false
  self._mmap.is_persist = 0
  -- destroy stuff not needed any more
  self._chunk = nil
  self._num_in_chunk = nil
  self._chunk_num = nil
  qc.c_free(self._filename) -- filename is now in _mmap
  if ( qconsts.debug ) then self:check() end
end

function Vector:persist()
   -- TODO Add routine to materialize if not already materialized
  assert(self._is_nascent == false)
  self._mmap.is_persist = 1
  -- local dbg = require 'Q/UTILS/lua/debugger'; dbg() 
end

function Vector:destroy()
  if ( self._chunk ) then 
    -- ffi.C.free(self._chunk)
    qc.c_free(self._chunk)
    self._chunk = nil
    self._chunk_num = nil
    self._num_in_chunk = nil
  end
  if ( self._mmap) then
    qc.f_munmap(self._mmap)
    self._mmap.map_addr = nil
    self._mmap.map_len = 0
    self._mmap = nil
  end
  self._num_elements = nil
end

function Vector:meta()
  local T = {}
  if ( self._file_name ) then 
    T.file_name = ffi.string(self._file_name)
  end
  if ( self._mmap ) then
    T.map_len = tonumber(self._mmap.map_len)
    T.file_name = ffi.string(self._mmap.file_name)
    T.is_persist = tonumber(self._mmap.is_persist)
  end
  return T
end

return require('Q/q_export').export('Vector', Vector)
