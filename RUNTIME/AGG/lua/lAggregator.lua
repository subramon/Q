local ffi             = require 'Q/UTILS/lua/q_ffi'
local qconsts         = require 'Q/UTILS/lua/q_consts'
local cmem            = require 'libcmem'
local Aggregator      = require 'libagg'
local register_type   = require 'Q/UTILS/lua/q_types'
local qc              = require 'Q/UTILS/lua/q_core'
local get_ptr         = require 'Q/UTILS/lua/get_ptr'
local parse_params    = require 'Q/RUNTIME/AGG/lua/parse_params'
--====================================
local lAggregator = {}
lAggregator.__index = lAggregator

setmetatable(lAggregator, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

register_type(lAggregator, "lAggregator")

local Q_RHM_SET = 1 -- TODO P3 Need better way to keep this in sync with C
local Q_RHM_ADD = 2  -- TODO P3 Need better way to keep this in sync with C
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

function lAggregator.new(params)
  local agg = setmetatable({}, lAggregator)
  local initial_size, keytype, valtype = parse_params(params)
  --==========================================
  agg._agg = assert(Aggregator.new(keytype, valtype, initial_size))
  local M = {}
  M._keytype  = keytype 
  M._valtype  = valtype 
  M._num_puts = 0
  M._num_gets = 0
  M._num_dels = 0
  M._chunk_idx = 0
  agg._meta = M
  if ( qconsts.debug ) then agg:check() end
  --==========================================
  return agg
end

local function set_update_type(update_type)
  if ( not update_type ) then 
    return  Q_RHM_SET 
  else
    update_type = string.upper(update_type)
    if ( update_type == "SET" ) then 
      return  Q_RHM_SET 
    elseif ( update_type == "ADD" ) then 
      return  Q_RHM_ADD
    else
      assert(nil)
    end
  end 
  return update_type
end

function lAggregator.save()
  -- returns 2 vectors, one for key and one for value 
  -- we don't have a corresponding restore, the "new" suffices
  -- TODO
end

function lAggregator:put1(key, val, update_type)
  assert(type(key) == "Scalar")
  assert(type(val) == "Scalar")
  self._update_type = set_update_type(update_type)
  local oldval = Aggregator.put1(self._agg, key, val, update_type)
  self._meta._num_puts = self._meta._num_puts + 1
  return oldval
end

function lAggregator:get_meta()
  local nitems, size =  Aggregator.get_meta(self._agg)
  local T = {}
  T.nitems = nitems
  T.size   = size
  T.num_puts   = self._num_puts
  T.num_gets   = self._num_gets
  T.num_dels   = self._num_dels
  return T, self._meta
end

function lAggregator:get1(key)
  assert(type(key) == "Scalar")
  local val, is_found = Aggregator.get1(self._agg, key, self._meta._valtype)
  assert(type(val) == "Scalar")
  self._meta._num_gets = self._meta._num_gets + 1
  if ( is_found ) then return val else return nil end 
end

function lAggregator:del1(key)
  assert(type(key) == "Scalar")
  local val, is_found = Aggregator.del1(self._agg, key, self._meta._valtype)
  self._meta._num_dels = self._meta._num_dels + 1
return val, is_found
end


function lAggregator:is_input()
  if ( self._valvec ) then return true else return false end
end 

function lAggregator:step()
  local v = assert(self._vecinfo._valvec)
  local k = assert(self._vecinfo._keyvec)
  local chunk_idx = assert(self._vecinfo._chunk_idx)
  if ( v:is_eov() ) then 
    self._vecinfo = nil
    return 0 -- number of items inserted
  end 
  assert( not k:is_eov() )
  local klen, kchunk = k:chunk(chunk_idx)
  local vlen, vchunk = v:chunk(chunk_idx)
  assert(klen == vlen)
  if ( klen == 0 ) then 
    self._vecinfo = nil
    return 0 -- number of items inserted
  end 
  assert(kchunk)
  assert(vchunk)

  self._vecinfo._chunk_idx = self._vecinfo._chunk_idx + 1
  assert(Aggregator.putn(
  self._agg,
  kchunk, 
  self._update_type,
  self._vecinfo._hashbuf,
  self._vecinfo._locbuf,
  self._vecinfo._tidbuf,
  self._vecinfo._num_threads,
  vchunk, 
  klen,
  self._vecinfo._isfbuf
  ))
  return klen -- number of items inserted
end

function lAggregator:delete()
  assert(Aggregator.delete(self._agg))
end

function lAggregator:check()
  -- TODO Can add a lot more tests here
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

local function set_in_cmem(agg, keyvec, valvec, update_type)
  if ( qconsts.debug ) then self:check() end
  assert(nil, "TODO To be implemented")
  return true
end

local function set_in_vec(agg, keyvec, valvec, update_type)
  if ( qconsts.debug ) then self:check() end
  local vecinfo = {}
  assert(type(agg) == "lAggregator")
  assert(type(keyvec) == "lVector")
  assert(type(valvec) == "lVector")
  local ktype = keyvec:fldtype()
  assert( ( ktype == "I1" ) or ( ktype == "I1" ) or 
          ( ktype == "I4" ) or ( ktype == "I8" ) )
  local vtype = valvec:fldtype()
  assert( ( vtype == "I1" ) or ( vtype == "I1" ) or 
          ( vtype == "I4" ) or ( vtype == "I8" ) or
          ( vtype == "F4" ) or ( vtype == "F8" ) )
  assert(not keyvec:has_nulls()) -- currently no support for nulls
  assert(not valvec:has_nulls()) -- currently no support for nulls

  vecinfo._keyvec = keyvec
  vecinfo._valvec = valvec
  vecinfo._chunk_idx = 0
  -- Note currently hash is uint32_t
  local hashwidth = ffi.sizeof("uint32_t")
  -- Note currently number of elements is uint32_t
  local locwidth  = ffi.sizeof("uint32_t")
  local tidwidth  = ffi.sizeof("uint8_t")
  local isfwidth  = ffi.sizeof("uint8_t")
  -- Allocate space for hash buffer and location buffer 
  vecinfo._hashbuf = assert(cmem.new(qconsts.chunk_size * hashwidth, "I4"))
  vecinfo._locbuf  = assert(cmem.new(qconsts.chunk_size * locwidth,  "I4"))
  vecinfo._tidbuf  = assert(cmem.new(qconsts.chunk_size * tidwidth,  "I1"))
  vecinfo._isfbuf  = assert(cmem.new(qconsts.chunk_size * isfwidth,  "I1"))
  vecinfo._num_threads = qc['q_omp_get_num_procs']()
  if ( qconsts.debug ) then agg:check() end
  agg._vecinfo = vecinfo
  return true
end

function lAggregator:set_in(key, val, update_type)
  if ( qconsts.debug ) then self:check() end
  self._update_type = set_update_type(update_type)
  if (type(key) == "lVector") then 
    return set_in_vec(self, key, val, update_type)
  elseif (type(key) == "CMEM") then 
    return set_in_cmem(self, key, val, update_type)
  else
    assert(nil, "Input to Aggregator must be vector or CMEM")
  end
end

function lAggregator:consume()
  if ( qconsts.debug ) then self:check() end
  assert(self._keyvec) 
  assert(self._valvec)
  assert(self._hashbuf) 
  assert(self._locbuf)
  assert(self._tidbuf)
  assert(self._isfbuf)
  local v, vlen = self._valvec:get_chunk(chunk_idx)
  local k, klen = self._keyvec:get_chunk(chunk_idx)
  -- either both k and v are null or neither are
  assert ( ( v and k ) or ( not v and not k ) )
  assert(vlen == klen)
  if ( vlen == 0 ) then -- nothing more to consume
    clean(self)
  else
    -- TODO do something here
  end
  if ( qconsts.debug ) then self:check() end
  return self
end

local function clean(x)
  x._keyvec = nil 
  x._valvec = nil
  if ( x._hashbuf ) then x._hashbuf:delete() end
  if ( x._locbuf ) then x._locbuf:delete() end
  if ( x._tidbuf ) then x._tidbuf:delete() end
  if ( x._isfbuf ) then x._isfbuf:delete() end
  x._hashbuf = nil 
  x._locbuf = nil
  x._tidbuf = nil
  x._isfbuf = nil
end

function lAggregator:unset_in()
  clean(self)
end

return lAggregator
