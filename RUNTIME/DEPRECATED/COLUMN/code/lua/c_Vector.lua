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

function Vector.new(arg)
  local vec = setmetatable({}, Vector)

  -- set qtype
  assert(type(arg) == "table", "argument to constructor should be table")
  local qtype = assert(arg.field_type, "must specify fldtype for vector")
  assert(type(qtype) == "string")
  assert(qconsts.qtypes[qtype], "Valid qtype not given")
  vec._field_type = qtype

  local status
  -- set field_size
  local fldsz
  if ( qtype == "SC" ) then 
    local fldsz = assert(arg.field_size, "Must specify field size for SC")
    assert(type(fldsz) == "number")
    assert(fldsz >= 2, "Field size must be >= 2 (one for nullc)")
    vec._field_size = fldszfield_size
  else
    assert(arg.field_size == nil, "Can specify field size only for SC")
    fldsz = qconsts.qtypes[qtype].width
  end
  vec._field_size = fldsz
  --==============================
  -- local dbg = require 'Q/UTILS/lua/debugger'
  -- dbg()
  vec._vec = ffi.malloc(ffi.sizeof("VEC_REC_TYPE"), qc.vec_free)
  vec._vec = ffi.cast("VEC_REC_TYPE *", vec._vec)
  qc.vec_new(vec._vec, qtype, fldsz, qconsts.chunk_size)
  --[[
  vec._vec = qc.vec_new(vec._field_type, vec._field_size, 
    qconsts.chunk_size)
    --]]
  assert(vec._vec)
  vec._vec = ffi.cast("VEC_REC_TYPE *", vec._vec)
  --==============================
  local is_read_only
  if ( arg.is_read_only ) and ( arg.is_read_only == true ) then 
    vec._is_read_only = true
  else
    vec._is_read_only = false
  end
  --====== is vector materialized or nascent
  assert(arg.is_nascent ~= nil)
  assert(type(arg.is_nascent) == "boolean")
  if arg.is_nascent == true then 
    vec._is_nascent = true
  else
    vec._is_nascent = false
  end
  --==============================
  if ( vec._is_nascent ) then 
    status = qc.vec_nascent(vec._vec)
  else
    local file_name = assert(arg.file_name)
    assert(type(file_name) == "string")
    status = qc.vec_materialized(vec._vec, arg.file_name, 
      vec._is_read_only);
  end
  assert(status == 0)
  --===================================
  print("Created vec")
  if ( qconsts.debug ) then qc.vec_check(vec._vec) end
  print("tested vec")
  return vec
end

function Vector:length()
  if ( qconsts.debug ) then qc.vec_check(self._vec) end
  return self._num_elements
end

function Vector:check()
  local status = qc.vec_check(self._vec)
  return status
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
  if ( qconsts.debug ) then qc.vec_check(self._vec) end
end

function Vector:set(addr, idx, len)
  assert(addr)
  assert(len)
  assert(type(len) == "number")
  assert(len >= 1)
  if ( self._is_nascent ) then assert(idx == nil) end 
  if ( idx == nil ) then idx = 0 end 

  addr = ffi.cast("char *", addr)
  qc.vec_set(self._vec, addr, idx, len)

  if ( qconsts.debug ) then qc.vec_check(self._vec) end
end

function Vector:get(idx, len)

  assert(idx)
  assert(type(idx) == "number")
  assert(idx >= 0)

  assert(len)
  assert(type(len) == "number")
  assert(len >= 1)
  local status = qc.vec_get(self._vec, idx, len)
  assert(status == 0)
  local addr = assert(self._vec.ret_addr)
  local len  = assert(self._vec.ret_len)
  if ( qconsts.debug ) then qc.vec_check(self._vec) end
  return addr, len

end

function Vector:eov(in_is_rdonly)
  local is_read_only
  if ( in_is_rdonly ~= nil ) and ( in_is_rdonly == true ) then 
    is_read_only = true
  else
    is_read_only = false
  end
  qc.vec_eov(self._vec, is_read_only)
  if ( qconsts.debug ) then qc.vec_check(self._vec) end
end

function Vector:persist()
   -- TODO Add routine to materialize if not already materialized
  assert(self._is_nascent == false)
  self._mmap.is_persist = 1
  -- local dbg = require 'Q/UTILS/lua/debugger'; dbg() 
end

function Vector:destroy()
  qc.vec_free(self._vec)
end

function Vector:meta()
  local T = {}

  T.field_type  = ffi.string(self._vec[0].field_type)

  T.field_size = tonumber(self._vec[0].field_size)
  T.chunk_size = tonumber(self._vec[0].chunk_size)

  T.num_elements = tonumber(self._vec[0].num_elements)
  T.num_in_chunk = tonumber(self._vec[0].num_in_chunk)
  T.chunk_num    = tonumber(self._vec[0].chunk_num)   

  
  T.file_name    = ffi.string(self._vec[0].file_name)
  T.map_addr     = tonumber(self._vec[0].map_addr)
  T.map_len      = tonumber(self._vec[0].map_len)
  T.is_persist   = tonumber(self._vec[0].is_persist)
  T.is_nascent   = tonumber(self._vec[0].is_nascent)
  T.status       = tonumber(self._vec[0].status)
  T.is_memo      = tonumber(self._vec[0].is_memo)
  T.is_read_only = tonumber(self._vec[0].is_read_only)
  T.chunk        = tonumber(self._vec[0].chunk)

  return T
end

return require('Q/q_export').export('Vector', Vector)
