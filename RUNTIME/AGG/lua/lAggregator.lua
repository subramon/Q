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
  local generator 
  if ( params.generator ) then 
    generator = params.generator
    -- data is put into the Aggregator in one of two ways
    -- Either we do get_chunk() which reads in a chunk of data from
    -- both the key vector and the val vector
    -- Or we put data one at a time
    assert( ( type(generator) == "function" ) or 
            ( type(generator) == "boolean" ) )
    agg._generator = generator
  end
  return agg
end

function lAggregator:set_input_mode(generator)
  assert(generator)
  assert( ( type(generator) == "function" ) or 
          ( type(generator) == "boolean" ) )
  assert(not self._generator) -- should not be set already
  self._generator = generator
end

function lAggregator.save()
  -- returns 2 vectors, one for key and one for value 
  -- we don't have a corresponding restore, the "new" suffices
  -- TODO
end

function lAggregator:put1(key, val, update_type)
  assert(self._generator)
  assert( type(self._generator) == "boolean" )
  assert(type(key) == "Scalar")
  assert(type(val) == "Scalar")
  if ( not update_type ) then update_type = "set" end 
  local oldval = Aggregator.put1(self._agg, key, val, update_type)
  self._num_puts = self._num_puts + 1
  return oldval
end

function lAggregator:get1(key)
  assert(self._generator)
  assert(type(key) == "Scalar")
  local val = Aggregator.get1(self._agg, key, self._valtype)
  self._num_gets = self._num_gets + 1
  return val
end

function lAggregator:del1(key)
  assert(self._generator)
  assert(type(key) == "Scalar")
  local val = Aggregator.del1(self._agg, key, self._valtype)
  self._num_dels = self._num_dels + 1
  return val
end


function lAggregator:next()
  assert(self._generator)
  assert( type(self._generator) == "function" )
  -- TODO Lot more to do here
  agg._chunk_index = agg._chunk_index + 1
  -- TODO assert(Aggregator.putn(key, val))
end

function lAggregator:delete()
  assert(Aggregator.delete(self._agg))
  for k, v in pairs(self) do self.k = nil end 
end

return lAggregator
