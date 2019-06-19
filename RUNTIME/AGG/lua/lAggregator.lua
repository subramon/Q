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
  initial_size, keytype, valtype = parse_params(params)
  --==========================================
  agg._agg = assert(Aggregator.new(keytype, valtype, initial_size))
  agg._keytype  = keytype 
  agg._valtype  = valtype 
  agg._num_puts = 0
  agg._num_gets = 0
  agg._num_dels = 0
  agg._chunk_index = 0
  if ( qconsts.debug ) then agg:check() end
  --==========================================
  return agg
end

function lAggregator.save()
  -- returns 2 vectors, one for key and one for value 
  -- we don't have a corresponding restore, the "new" suffices
  -- TODO
end

function lAggregator:put1(key, val, update_type)
  assert(type(key) == "Scalar")
  assert(type(val) == "Scalar")
  if ( not update_type ) then 
    update_type = "SET" 
  else
    update_type = string.upper(update_type)
    assert ( ( update_type == "SET" ) or ( update_type == "ADD" ) )
  end 
  local oldval = Aggregator.put1(self._agg, key, val, update_type)
  self._num_puts = self._num_puts + 1
  return oldval
end

function lAggregator:get1(key)
  assert(type(key) == "Scalar")
  local val, is_found = Aggregator.get1(self._agg, key, self._valtype)
  assert(type(val) == "Scalar")
  self._num_gets = self._num_gets + 1
  if ( is_found ) then return val else return nil end 
end

function lAggregator:del1(key)
  assert(type(key) == "Scalar")
  local val = Aggregator.del1(self._agg, key, self._valtype)
  self._num_dels = self._num_dels + 1
  return val
end


function lAggregator:attach_input(k, v)
  assert(type(k) == "lVector")
  assert(type(v) == "lVector")
  local ktype = k:fldtype()
  local vtype = v:fldtype()
  assert(good_key_types(ktype))
  assert(good_val_types(vtype))
  agg._key_vec = k
  agg._val_vec = v
  agg._chunk_index = 0
  return self
end

function lAggregator:is_input()
  if ( self._val_vec ) then return true else return false end
end 

function lAggregator:next()
  local v = assert(self._val_vec)
  local k = assert(self._key_vec)
  local chunk_index = assert(self._chunk_index)
  if ( v:is_eov() ) then 
    self._key_vec = nil
    self._val_vec = nil
    self._chunk_index = nil
    return self
  end 
  assert( not k:is_eov() )
  local klen, kchunk = key_vec:chunk(chunk_idx)
  local vlen, vchunk = val_vec:chunk(chunk_idx)
  assert(klen == vlen)
  if ( klen == 0 ) then 
    self._key_vec = nil
    self._val_vec = nil
    self._chunk_index = nil
    return self
  end 
  assert(kchunk)
  assert(vchunk)

  local k_ctype = qconsts.qtypes[k:fldtype()].ctype
  local v_ctype = qconsts.qtypes[k:fldtype()].ctype
  local cast_k_as = k_ctype .. " *"
  local cast_v_as = v_ctype .. " *"

  agg._chunk_index = agg._chunk_index + 1
  -- TODO assert(Aggregator.putn(key, val))
end

function lAggregator:delete()
  assert(Aggregator.delete(self._agg))
  for k, v in pairs(self) do self.k = nil end 
end

function lAggregator:check()
  -- TODO Can add a lot more tests here
  if ( self._key_vec ) then 
    assert(good_key_types(k:fldtype()))
    assert(good_val_types(v:fldtype()))
    assert(self._val_vec)
    assert(self._chunk_index)

    assert(type(self._key_vec) == "lVector")
    assert(type(self._val_vec) == "lVector")
    assert(type(self._chunk_index) == "number")

    assert(self._chunk_index > 0)
  else
    assert(not self._val_vec)
    assert(not self._chunk_index)
  end
  return true
end 

function lAggregator:set_in(key, val)
  if ( qconsts.debug ) then self:check() end
  if (type(keyvec) == "lVector") then 
    return lAggregator:set_in_vec(key, val)
  elseif (type(keyvec) == "CMEM") then 
    return lAggregator:set_in_cmem(key, val)
  else
    assert(nil, "Input to Aggregator must be vector or CMEM")
  end
end

function lAggregator:set_in_cmem(keyvec, valvec)
  if ( qconsts.debug ) then self:check() end
  assert(nil, "TODO To be implemented")
  return true
end

function lAggregator:set_in_vec(keyvec, valvec)
  if ( qconsts.debug ) then self:check() end
  assert(type(keyvec) == "lVector")
  assert(type(valvec) == "lVector")
  local ktype = keyvec:fldtype()
  assert( ( ktype == "I1" ) or ( ktype == "I1" ) or 
          ( ktype == "I4" ) or ( ktype == "I8" ) )
  assert( ( vtype == "I1" ) or ( vtype == "I1" ) or 
          ( vtype == "I4" ) or ( vtype == "I8" ) or
          ( vtype == "F4" ) or ( vtype == "F8" ) )
  assert(not keyvec:has_nulls()) -- currently no support for nulls
  assert(not valvec:has_nulls()) -- currently no support for nulls

   self._keyvec = keyvec
   self._valvec = valvec
   self._chunk_idx = 0
   -- Note currently hash is uint32_t
   local hashwidth = ffi.sizeof("uint32_t")
   -- Note currently number of elements is uint32_t
   local locwidth  = ffi.sizeof("uint32_t")
   local tidwidth  = ffi.sizeof("uint8_t")
   -- Allocate space for hash buffer and location buffer 
   self._hashbuf = assert(cmem.new(qconsts.chunk_size * hashwidth))
   self._locbuf  = assert(cmem.new(qconsts.chunk_size * locwidth))
   self._tidbuf  = assert(cmem.new(qconsts.chunk_size * tidwidth))
  if ( qconsts.debug ) then self:check() end
  return true
end

function lAggregator:consume()
  if ( qconsts.debug ) then self:check() end
  assert(self._keyvec) 
  assert(self._valvec)
  assert(self._hashbuf) 
  assert(self._locbuf)
  assert(self._tidbuf)
  local v, vlen = self._valvec:get_chunk(chunk_idx)
  local k, klen = self._keyvec:get_chunk(chunk_idx)
  -- either both k and v are null or neither are
  assert ( ( v and k ) or ( not v and not k ) )
  assert(vlen == klen)
  if ( vlen == 0 ) then -- nothing more to consume
    -- delete links to val and key vec
    self._valvec = nil
    self._keyvec = nil
    -- free buffers created for hash and loc
    self._hashbuf:delete()
    self._locbuf:delete()
    self._tidbuf:delete()
  else
    -- TODO do something here
  end
  if ( qconsts.debug ) then self:check() end
  return self
end

function lAggregator:unset_in()
  if ( qconsts.debug ) then self:check() end
  self._keyvec = nil 
  self._valvec = nil
  if ( self._hashbuf ) then self._hashbuf:delete() end
  if ( self._locbuf ) then self._locbuf:delete() end
  if ( self._tidbuf ) then self._tidbuf:delete() end
  self._hashbuf = nil 
  self._locbuf = nil
  self._tidbuf = nil
  local v, vlen = self._valvec:get_chunk(chunk_idx)
  local k, klen = self._keyvec:get_chunk(chunk_idx)
  -- either both k and v are null or neither are
  assert ( ( v and k ) or ( not v and not k ) )
  assert(vlen == klen)
  if ( vlen == 0 ) then -- nothing more to consume
    -- delete links to val and key vec
    self._valvec = nil
    self._keyvec = nil
    -- free buffers created for hash and loc
  else
    -- TODO do something here
  end
  if ( qconsts.debug ) then self:check() end
  return self
end

return lAggregator
