local ffi = require 'ffi'
local qconsts         = require 'Q/UTILS/lua/q_consts'
local cmem            = require 'libcmem'
local register_type   = require 'Q/UTILS/lua/q_types'
local qc              = require 'Q/UTILS/lua/q_core'
local to_scalar       = require 'Q/UTILS/lua/to_scalar'
local get_ptr         = require 'Q/UTILS/lua/get_ptr'
local lVector         = require 'Q/RUNTIME/lua/lVector'
local libgen          = require 'Q/RUNTIME/MAGG/lua/libgen'
  local Aggregator      = require 'libagg' -- TODO THIS IS A HACK
--====================================
local lAggregator = {}
lAggregator.__index = lAggregator

setmetatable(lAggregator, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

register_type(lAggregator, "lAggregator")

local function good_key_types(ktype)
  assert( ( ktype == "I4" ) or ( ktype == "I8" ) )
  return true
end

local function good_val_types(vtype)
  assert( ( vtype == "I1" ) or ( ktype == "I2" ) or
          ( vtype == "I4" ) or ( ktype == "I8" ) or
          ( vtype == "F4" ) or ( ktype == "F8" ) )
  return true
end

local function clean(x, str)
  if ( str ) then print(str) end 
  if ( x._bufinfo ) then 
    if ( x._bufinfo._valbuf ) then x._bufinfo._valbuf:delete() end
    if ( x._bufinfo._hshbuf ) then x._bufinfo._hshbuf:delete() end
    if ( x._bufinfo._locbuf  ) then x._bufinfo._locbuf:delete() end
    if ( x._bufinfo._tidbuf  ) then x._bufinfo._tidbuf:delete() end
    if ( x._bufinfo._fndbuf  ) then x._bufinfo._fndbuf:delete() end
  end
  x._bufinfo = nil
  x._vecinfo = nil
end

local function is_clean(x)
  if ( x._vecinfo ~= nil ) then return false end 
  if ( x._bufinfo ~= nil ) then return false end 
  return true
end

function lAggregator:is_clean() -- for debugging
  local rslt =  is_clean(self)
  return rslt
end 

function lAggregator:instantiate()
  assert ( self._is_instantiated == false)
  local initial_size = self._params.initial_size
  if ( not initial_size ) then initial_size = 0 end
  assert(Aggregator.instantiate(self._agg, initial_size))
  -- TODO assert(libgen(params))

  self._is_instantiated = true
  return true
end

function lAggregator:bufferize()
  assert ( self._is_instantiated == true)
  assert ( self._is_bufferized == false)
  assert(Aggregator.bufferize(self._agg, qconsts.chunk_size))
  self._is_bufferized = true
  return true
end

function lAggregator:unbufferize()
  assert ( self._is_instantiated == true)
  assert ( self._is_bufferized == true)
  assert(Aggregator.unbufferize(self._agg))
  self._is_bufferized = false
  return true
end

function lAggregator.new(params)
  local agg = setmetatable({}, lAggregator)
  -- We could delay generating .so file and creating aggregator
  -- until it is actually used but going to do it now.
  --
  -- make sure that separate libagg is created for each aggregator
  -- more specificaally for each unique params
  -- TODO assert(libgen(params))
  local Aggregator      = require 'libagg'
  --==========================================
  agg._params = params -- to record how it was created
  -- added tbl as a sample code to verify my understanding
  local tbl = { }
  local test_tbl = {}
  local num_vals = assert(#params.vals)
  for i = 1, num_vals do tbl[#tbl+1] = "string_" .. i end 
  agg._agg, test_tbl = assert(Aggregator.new(tbl))
  for i = 1, num_vals do assert(test_tbl[i] == tbl[i]) end 
  local M = {}
  M._num_puts = 0
  M._num_gets = 0
  M._num_dels = 0
  M._chunk_idx = 0
  agg._meta = M
  agg._is_instantiated = false
  agg._is_bufferized = false
  agg._is_dead = false
  agg._is_eov = false
  if ( qconsts.debug ) then agg:check() end
  --==========================================
  return agg
end

local function mk_bufs(p)
  if ( p ) then print("mk_bufs: " .. p) end -- for debugging
  local valwidth = ffi.sizeof("val_t") -- TODO prefix label
  -- Note currently hsh is uint32_t
  local hshwidth = ffi.sizeof("uint32_t")
  -- Note currently number of elements is uint32_t
  local locwidth  = ffi.sizeof("uint32_t")
  local tidwidth  = ffi.sizeof("uint8_t")
  local isfwidth  = ffi.sizeof("uint8_t")
  local bufinfo = {}
  -- valbuf for composite values
  bufinfo._valbuf = assert(cmem.new(qconsts.chunk_size * valwidth,
    "", "valbuf"))
  -- hasbuf for hsh of key
  bufinfo._hshbuf = assert(cmem.new(qconsts.chunk_size * hshwidth, 
    "I4", "hshbuf"))
  -- locbuf for initial probe point
  bufinfo._locbuf  = assert(cmem.new(qconsts.chunk_size * locwidth,  
    "I4", "locbuf"))
  -- tidbuf for thread ID assigned to it
  bufinfo._tidbuf  = assert(cmem.new(qconsts.chunk_size * tidwidth,  
    "I1", "tidbuf"))
  -- fndbuf for "is found"
  bufinfo._fndbuf  = assert(cmem.new(qconsts.chunk_size * isfwidth,  
    "I1", "fndbuf"))
  bufinfo._num_threads = qc['q_omp_get_num_procs']()
  return bufinfo 
end

function lAggregator.save()
  -- TODO P2
end

function lAggregator.restore()
  -- TODO P2
end

function lAggregator:put1(key, vals)
  assert ( self._is_dead == false ) 
  if ( self._is_instantiated == false ) then self:instantiate() end
  --==============
  local invaltype 
  assert(key)
  assert(vals)
  if ( type(key) == "number" ) then 
    key = to_scalar(key, self._params.keytype)
  end
  if ( type(vals) == "number" ) then 
    vals = to_scalar(vals, self._params.keytype)
  end
  if ( type(vals) == "Scalar" ) then 
    vals = { vals }
    invaltype = "Scalar"
  else
    invaltype = "table"
  end
  assert(type(vals) == "table")
  local cnt = 0
  for i, v in ipairs(vals) do 
    if ( type(v) == "number" ) then 
      vals[i] = assert(to_scalar(v, self._params.vals[i].valtype))
    end
    assert(type(vals[i]) == "Scalar" )
  end
  --==============
  local oldvals, updated = assert(Aggregator.put1(self._agg, key, vals))
  self._meta._num_puts = self._meta._num_puts + 1
  if ( qconsts.debug ) then 
    assert(type(updated) == "boolean" )
    assert(type(oldvals) == "table" )
    for  i, v in ipairs(oldvals) do 
      assert(type(v) == "Scalar" ) 
    end
    self:check() 
  end 
  if ( invaltype == "Scalar" ) then 
    oldvals = oldvals[1]
    assert(type(oldvals) == "Scalar" ) 
  end
  return oldvals, updated
end

function lAggregator:meta()
  local M = Aggregator.meta(self._agg) -- stuff stored by C
  for k, v in pairs(self._meta) do M[k] = v end
  return M
end

function lAggregator:get1(key)
  assert ( self._is_dead == false ) 
  if ( self._is_instantiated == false ) then return nil end
  assert(key)
  if ( type(key) == "number" ) then 
    key = to_scalar(key, self._params.keytype)
  end
  local is_found, cnt, val = Aggregator.get1(self._agg, key)
  self._meta._num_gets = self._meta._num_gets + 1
  if ( qconsts.debug ) then 
    assert(type(is_found) == "boolean")
    if ( is_found ) then 
      assert(type(cnt) == "number")
      assert(type(val) == "table")
      for i, v in pairs(val) do 
        assert(v:fldtype() == self._params.vals[i].valtype)
      end
    else
      assert(type(val) == "nil")
      assert(type(cnt) == "nil")
    end
    self:check() 
  end
  return is_found, cnt, val
end

function lAggregator:del1(key)
  assert ( self._is_dead == false ) 
  if ( self._is_instantiated == false ) then return false, nil end
  assert(key)
  if ( type(key) == "number" ) then 
    key = to_scalar(key, self._params.keytype)
  end
  local is_found, val = Aggregator.del1(self._agg, key)
  self._meta._num_dels = self._meta._num_dels + 1
  if ( qconsts.debug ) then 
    assert(type(is_found) == "boolean")
    if ( is_found ) then 
      assert(type(val) == "table")
      for i, v in pairs(val) do 
        assert(v:fldtype() == self._params.vals[i].valtype)
      end
    else
      assert(type(val) == "nil")
    end
    self:check() 
  end
  return is_found, val
end


function lAggregator:is_input()
  if ( self._valvec ) then return true else return false end
end 

function lAggregator:consume()
  assert ( self._is_dead == false ) 
  if ( self._is_instantiated == false ) then self:instantiate() end
  if ( self._is_bufferized   == false ) then self:bufferize() end


  local v = assert(self._vecinfo._valvec)
  local k = assert(self._vecinfo._keyvec)
  local chunk_idx = assert(self._vecinfo._chunk_idx)
  if ( v:is_eov() ) then 
    assert(Aggregator.unubufferize(self._agg))
    self._is_bufferized = false
    return 0 -- number of items inserted
  end 
  assert( not k:is_eov() )
  local klen, kchunk = k:chunk(chunk_idx)
  local vlen, vchunk = v:chunk(chunk_idx)
  assert(klen == vlen)
  assert(kchunk)
  assert(vchunk)

  -- TODO call to putn
  self._vecinfo._chunk_idx = self._vecinfo._chunk_idx + 1
  if ( klen < qconsts.chunk_size ) then 
    self._is_eov = true
    assert(Aggregator.unubufferize(self._agg))
    self._is_bufferized = false
  end 

  return klen -- number of items inserted
end

function lAggregator:delete()
  assert(Aggregator.delete(self._agg))
  self._is_dead = true
  -- TODO Delete any buffers created on Lua side 
end

function lAggregator:check()
  -- TODO P3 Can add a lot more tests here
  if ( self._keyvec ) then 
    assert(good_key_types(k:fldtype()))
    assert(good_val_types(v:fldtype()))
    assert(self._valvec)
    assert(self._chunk_idx)

    assert(type(self._keyvec) == "lVector")
    assert(type(self._valvec) == "lVector")
    assert(type(self._chunk_idx) == "number")

    assert(self._chunk_idx > 0)
  else
    assert(not self._valvec)
    assert(not self._chunk_idx)
  end
  return true
end 

function lAggregator:set_consume(keyvec, valvecs)
  assert ( self._is_dead == false ) 
  if ( self._is_instantiated == false ) then self:instantiate() end
  if ( qconsts.debug ) then self:check() end

  assert ( not self._keyvec ) -- no key vector set
  assert(type(keyvec) == "lVector")
  self._keyvec = keyvec
  
  if ( type(valvecs) == "lVector") then
    valvecs = { valvecs }
  end
  if ( type(valvecs) == "table") then
    local cnt = 0
    -- compare type of v against how Aggregator was created
    for k, v in ipairs(valvecs) do 
      assert(type(v) == "lVector")
      local x = assert(self._params[k])
      assert(x.valtype == v:fldtype())
      cnt = cnt + 1 
    end
    assert(cnt == #self._params.vals)
  else
    assert(nil, "invalid values")
  end

  local vecinfo = {}

  local ktype = keyvec:fldtype()
  assert(ktype == self._meta._keytype)

  local vtype = valvec:fldtype()
  assert(vtype == self._meta._valtype)

  assert(not keyvec:has_nulls()) -- currently no support for nulls
  assert(not valvec:has_nulls()) -- currently no support for nulls

  vecinfo._keyvec = keyvec
  vecinfo._valvec = valvec
  vecinfo._chunk_idx = 0
  -- Allocate space for buffers
  self._vecinfo = vecinfo
  self._bufinfo = mk_bufs()
  return true
end

function lAggregator:get_in(key)
  if ( qconsts.debug ) then self:check() end
  if (type(key) == "lVector") then 
    return get_in_vec(self, val)
  else
    assert(nil, "Input to Aggregator must be vector ")
  end
  return true
end

function lAggregator:unset_consume()
  clean(self, "unset_consume")
  return true
end

function lAggregator:unset_produce()
  assert ( self._keyvec ) -- key vector set
  self._keyvec = nil
  return self
end

function lAggregator:set_produce(in_keyvec)
  assert ( self._is_instantiated == true )
  if ( qconsts.debug ) then self:check() end
  assert(type(in_keyvec) == "lVector")
  local keytype = in_keyvec:fldtype()
  assert( keytype == self._params.keytype )
  self._keyvec = in_keyvec

  --[[ TODO 
  --==============================================
  local valtype = self._meta._valtype
  local val_buf 
  local chunk_idx = 0
  local first_call = true
  --==============================================
  local key_ctype = qconsts.qtypes[keytype].ctype
  local val_ctype = qconsts.qtypes[valtype].ctype
  local key_cast_as = key_ctype .. " * "
  local val_cast_as = val_ctype .. " * "
  --==============================================

  local function valgen (chunk_num)
    assert(chunk_num == chunk_idx)
    if ( first_call ) then
      first_call = false
      local bufsz = qconsts.chunk_size * qconsts.qtypes[valtype].width
      val_buf = assert(cmem.new(bufsz, valtype))
    end
    local key_len, key_chunk, nn_key_chunk
    key_len, key_chunk, nn_key_chunk = keyvec:chunk(chunk_idx)
    if key_len > 0 then
      local chunk1 = ffi.cast(key_cast_as,  get_ptr(key_chunk))
      local start_time = qc.RDTSC()
      -- TODO Here is the call 
    else
      val_buf = nil
    end
    chunk_idx = chunk_idx + 1
    return key_len, val_buf
  end
  valvec = lVector( { qtype = valtype, gen = valgen, has_nulls = false} )
  return valvec
  --]]
  return true
end

return lAggregator
