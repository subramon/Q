local ffi             = require 'ffi'
local qconsts         = require 'Q/UTILS/lua/q_consts'
local cmem            = require 'libcmem'
local register_type   = require 'Q/UTILS/lua/q_types'
local qc              = require 'Q/UTILS/lua/q_core'
local to_scalar       = require 'Q/UTILS/lua/to_scalar'
local lVector         = require 'Q/RUNTIME/lua/lVector'
local libgen          = require 'Q/RUNTIME/MAGG/lua/libgen'
local Aggregator      -- will be set in instantiate()
--====================================
local lAggregator = {}
lAggregator.__index = lAggregator

setmetatable(lAggregator, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

register_type(lAggregator, "lAggregator")

local function  mk_so(params)
  assert(libgen(params))
  return require(params.so)
  -- make sure that separate libagg is created for each aggregator
  -- more specifically for each unique params
end

function lAggregator:instantiate()
  assert ( self._is_instantiated == false)
  local initial_size = self._params.initial_size
  if ( not initial_size ) then initial_size = 0 end
  assert(Aggregator.instantiate(self._agg, initial_size))

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
  --==========================================
  agg._params = params -- to record how it was created
  -- We use intbl and outtbl just to verify my understanding
  -- They have no real use beyond that
  local intbl = { }
  local outtbl
  local num_vals = assert(#params.vals)
  for i = 1, num_vals do intbl[#intbl+1] = "string_" .. i end 
  Aggregator = assert(mk_so(params))
  agg._agg, outtbl = assert(Aggregator.new(intbl))
  for i = 1, num_vals do assert(outtbl[i] == intbl[i]) end 
  local M = {}
  M._num_puts = 0
  M._num_gets = 0
  M._num_dels = 0
  agg._meta = M
  agg._is_instantiated = false
  agg._is_bufferized   = false
  agg._is_dead         = false
  agg._is_eov          = false
  agg._chunk_idx       = 0
  agg._num_threads     = qc['q_omp_get_num_procs']()
  if ( qconsts.debug ) then agg:check() end
  --==========================================
  return agg
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
  local invaltype  -- to remember whether val was given to us as a
  -- Scalar or a table to make sure that we return it in same way
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

function lAggregator:is_bufferized()
  return self._is_bufferized
end

function lAggregator:is_instantiated()
  return self._is_instantiated
end

function lAggregator:is_dead()
  return self._is_dead
end

function lAggregator:meta()
  local M = Aggregator.meta(self._agg) -- stuff stored by C
  for k, v in pairs(self._meta) do M[k] = v end
  return M
end

function lAggregator:get1(key)
  assert ( self._is_dead == false ) 
  assert(key)
  if ( self._is_instantiated == false ) then return false end
  if ( type(key) == "number" ) then 
    key = to_scalar(key, self._params.keytype)
  end
  local is_found, cnt, val = Aggregator.get1(self._agg, key)
  self._meta._num_gets = self._meta._num_gets + 1
  if ( qconsts.debug ) then 
    assert(type(is_found) == "boolean")
    if ( is_found ) then 
      assert(type(cnt) == "number")
      assert(cnt >= 1 )
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

function lAggregator:consume()
  assert ( self._is_dead == false ) 
  if ( self._is_instantiated == false ) then self:instantiate() end
  if ( self._is_bufferized   == false ) then self:bufferize() end
  if ( self._is_eov   == true ) then return 0 end 

  local chunk_idx = assert(self._chunk_idx)
  assert(chunk_idx >= 0)
  num_threads     = assert(self._num_threads)
  assert(num_threads >= 1)

  local k = assert(self._inkeyvec)
  assert( not k:is_eov() )
  local klen, kchunk = k:chunk(chunk_idx)
  assert(klen > 0)
  assert(kchunk)
  

  local vs = assert(self._valvecs)
  local vlens = {}
  local vchunks = {}
  for k, v in ipairs(vs) do 
    assert( not v:is_eov() )
    local vlen, vchunk = v:chunk(chunk_idx)
    vlens[k]   = vlen
    vchunks[k] = vchunk
    assert(klen == vlen)
    assert(vchunk)
  end

  local status = Aggregator.putn(self._agg, kchunk, klen, num_threads, vchunks)
  self._chunk_idx = self._chunk_idx + 1
  if ( klen < qconsts.chunk_size ) then 
    self._is_eov = true
    assert(Aggregator.unbufferize(self._agg))
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
  -- TODO 
  return true
end 

function lAggregator:set_consume(keyvec, valvecs)
  assert ( self._is_dead == false, "aggregator is dead")
  if ( self._is_instantiated == false ) then self:instantiate() end
  if ( qconsts.debug ) then self:check() end

  -- check the key vector 
  assert ( not self._keyvec )  -- no key vector set
  assert ( not self._valvecs ) -- no val vectors set
  assert(type(keyvec) == "lVector")
  self._inkeyvec = keyvec
  assert(keyvec:has_nulls() == false) -- currently no support for nulls
  assert(keyvec:fldtype() == self._params.keytype)
  
  -- check the value vectors
  if ( type(valvecs) == "lVector") then
    valvecs = { valvecs }
  end
  if ( type(valvecs) == "table") then
    local cnt = 0
    -- compare type of v against how Aggregator was created
    for k, v in ipairs(valvecs) do 
      assert(type(v) == "lVector")
      assert(v:has_nulls() == false) -- currently no support for nulls
      assert(self._params.vals[k].valtype == v:fldtype())
      cnt = cnt + 1 
    end
    assert(cnt == #self._params.vals)
  else
    assert(nil, "invalid values")
  end

  self._valvecs  = valvecs
  return true
end

function lAggregator:unset_produce()
  assert ( self._outkeyvec ) -- key vector set
  self._outkeyvec = nil
  return self
end

function lAggregator:set_produce(keyvec)
  -- not an errro: assert ( self._is_instantiated == true )
  -- set_produce can be called only after set_consume
  assert(self._inkeyvec)
  assert(self._valvecs)

  assert ( type(self._outkeyvec) == "nil" ) -- key vector not set
  if ( qconsts.debug ) then self:check() end
  assert(type(keyvec) == "lVector")
  local keytype = keyvec:fldtype()
  assert( keytype == self._params.keytype )
  self._outkeyvec = keyvec

  local chunk_idx = 0
  local first_call = true
  local val_bufs = {}
  local val_vecs = {}

  for k, v in pairs(self._params.vals) do
    local valtype = v.valtype
    local function valgen (chunk_num)
      assert(chunk_num == chunk_idx)
      if ( first_call ) then
        first_call = false
        for k, v in pairs(self._params.vals) do
          local valtype = v.valtype
          local bufsz = qconsts.chunk_size * qconsts.qtypes[valtype].width
          val_bufs[k] = assert(cmem.new(bufsz, valtype))
        end
      end
      local key_len, key_chunk, nn_key_chunk = keyvec:chunk(chunk_idx)
      if ( key_len == 0 ) then 
        -- delete all val_bufs except mine 
        return 0 
      end 
      -- TODO local status = Aggregator.getn(key_chunk, val_bufs)
  
      chunk_idx = chunk_idx + 1
      return key_len, val_buf
    end
    val_vecs[k] = lVector( { qtype = valtype, gen = valgen, has_nulls = false} )
  end
  return val_vecs
end

return lAggregator
