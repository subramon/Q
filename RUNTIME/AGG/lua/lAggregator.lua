local ffi = require 'ffi'
local qconsts         = require 'Q/UTILS/lua/q_consts'
local cmem            = require 'libcmem'
local Aggregator      = require 'libagg'
local register_type   = require 'Q/UTILS/lua/q_types'
local qc              = require 'Q/UTILS/lua/q_core'
local get_ptr         = require 'Q/UTILS/lua/get_ptr'
local parse_params    = require 'Q/RUNTIME/AGG/lua/parse_params'
local lVector         = require 'Q/RUNTIME/lua/lVector'
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
local Q_RHM_ADD = 2 -- TODO P3 Need better way to keep this in sync with C
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
    if ( x._bufinfo._hashbuf ) then x._bufinfo._hashbuf:delete() end
    if ( x._bufinfo._locbuf  ) then x._bufinfo._locbuf:delete() end
    if ( x._bufinfo._tidbuf  ) then x._bufinfo._tidbuf:delete() end
    if ( x._bufinfo._isfbuf  ) then x._bufinfo._isfbuf:delete() end
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
  assert(nil)
end

local function mk_bufs(p)
  if ( p ) then print("mk_bufs: " .. p) end -- for debugging
  -- Note currently hash is uint32_t
  local hashwidth = ffi.sizeof("uint32_t")
  -- Note currently number of elements is uint32_t
  local locwidth  = ffi.sizeof("uint32_t")
  local tidwidth  = ffi.sizeof("uint8_t")
  local isfwidth  = ffi.sizeof("uint8_t")
  local bufinfo = {}
  -- hasbuf for hash of key
  bufinfo._hashbuf = assert(cmem.new(qconsts.chunk_size * hashwidth, 
    "I4", "hashbuf"))
  -- locbuf for initial probe point
  bufinfo._locbuf  = assert(cmem.new(qconsts.chunk_size * locwidth,  
    "I4", "locbuf"))
  -- tidbuf for thread ID assigned to it
  bufinfo._tidbuf  = assert(cmem.new(qconsts.chunk_size * tidwidth,  
    "I1", "tidbuf"))
  -- isfbuf for "is found"
  bufinfo._isfbuf  = assert(cmem.new(qconsts.chunk_size * isfwidth,  
    "I1", "isfbuf"))
  bufinfo._num_threads = qc['q_omp_get_num_procs']()
  return bufinfo 
end

function lAggregator.save()
  -- Could do one od 2 things
  -- (1) returns 2 vectors, one for key and one for value 
  -- (2) dump the buckets as binary file and restore from file
  -- TODO P2
end

function lAggregator.restore()
  -- TODO P2
end

function lAggregator:put1(key, val, update_type)
  assert(type(key) == "Scalar")
  assert(type(val) == "Scalar")
  self._update_type = set_update_type(update_type)
  local oldval = Aggregator.put1(self._agg, key, val, self._update_type)
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

function lAggregator:consume()
  local v = assert(self._vecinfo._valvec)
  local k = assert(self._vecinfo._keyvec)
  local chunk_idx = assert(self._vecinfo._chunk_idx)
  if ( v:is_eov() ) then 
    clean(self) -- , "eov for consume")
    return 0 -- number of items inserted
  end 
  assert( not k:is_eov() )
  local klen, kchunk = k:chunk(chunk_idx)
  local vlen, vchunk = v:chunk(chunk_idx)
  assert(klen == vlen)
  if ( klen == 0 ) then 
    clean(self) -- , "klen == 0 for consume")
    return 0 -- number of items inserted
  end 
  assert(kchunk)
  assert(vchunk)

  self._vecinfo._chunk_idx = self._vecinfo._chunk_idx + 1

  assert(Aggregator.putn(
  self._agg,
  kchunk, 
  self._update_type,
  self._bufinfo._hashbuf,
  self._bufinfo._locbuf,
  self._bufinfo._tidbuf,
  self._bufinfo._num_threads,
  vchunk, 
  klen,
  self._bufinfo._isfbuf
  ))

  return klen -- number of items inserted
end

function lAggregator:delete()
  assert(Aggregator.delete(self._agg))
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


function lAggregator:set_consume(keyvec, valvec, update_type)
  if ( qconsts.debug ) then self:check() end
  if ( not is_clean(self) ) then return false end 
  self._update_type = set_update_type(update_type)
  assert(type(keyvec) == "lVector")
  assert(type(valvec) == "lVector")

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
  -- Allocate space for hash buffer and location buffer 
  self._vecinfo = vecinfo
  self._bufinfo = mk_bufs()
  return true
end

function lAggregator:get_in(key, update_type)
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

function lAggregator:set_produce(in_keyvec)
  if ( qconsts.debug ) then self:check() end
  assert(type(in_keyvec) == "lVector")
  local keytype = in_keyvec:fldtype()
  assert( keytype == self._meta._keytype )
  local keyvec = in_keyvec -- TODO P4 Do we need this?
  if ( not self._bufinfo ) then self._bufinfo = mk_bufs() end

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
        --[[
  extern int 
  q_rhashmap_getn(
      q_rhashmap_t *hmap, 
      KEYTYPE  *keys, // [nkeys] 
      uint32_t *hashes, // [nkeys] 
      uint32_t *locs, // [nkeys] 
      VALTYPE  *vals, // [nkeys] 
      uint32_t nkeys
      );
  --]]
      Aggregator.getn(
        self._agg,
        key_chunk,
        self._bufinfo._hashbuf,
        self._bufinfo._locbuf,
        val_buf,
        key_len)
    else
      val_buf = nil
    end
    chunk_idx = chunk_idx + 1
    return key_len, val_buf
  end
  valvec = lVector( { qtype = valtype, gen = valgen, has_nulls = false} )
  return valvec
end

return lAggregator
