local ffi             = require 'Q/UTILS/lua/q_ffi'
local qconsts         = require 'Q/UTILS/lua/q_consts'
local cmem            = require 'libcmem'
local Aggregator      = require 'libagg'
local register_type   = require 'Q/UTILS/lua/q_types'
local qc              = require 'Q/UTILS/lua/q_core'
local get_ptr         = require 'Q/UTILS/lua/get_ptr'
local parse_params    = require 'Q/RUNTIME/AGG/lua/parse_params'
--====================================
local lagg = {}
lagg.__index = lagg

setmetatable(lagg, {
   __call = function (cls, ...)
      return cls.new(...)
   end,
})

register_type(lagg, "lagg")

function lagg.new(params)
  local agg = setmetatable({}, lagg)
  initial_size, keytype, valtype = parse_params(params)
  --==========================================
  agg._agg = assert(Aggregator.new(initial_size, keytype, valtype))
  agg._keytype  = keytype 
  agg._valtype  = valtype 
  agg._num_puts = 0
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
  print("CREATED Aggregator")
  return agg
end

function lagg.set_input_mode(generator)
  assert(generator)
  assert( ( type(generator) == "function" ) or 
          ( type(generator) == "boolean" ) )
  assert(not self._generator) -- should not be set already
  self._generator = generator
end

function lagg.save()
  -- returns 2 vectors, one for key and one for value 
  -- we don't have a corresponding restore, the "new" suffices
  -- TODO
end

function lagg.put(key, val)
  assert(self._generator)
  assert( type(self._generator) == "boolean" )
  local key = toscalar(key, self._keytype)
  local val = toscalar(val, self._valtype)
  agg._num_puts = agg._num_puts + 1
  assert(Aggregator.put1(key, val))
end

function lagg.get_chunk()
  assert(self._generator)
  assert( type(self._generator) == "function" )
  agg._chunk_index = agg._chunk_index + 1
  -- TODO Lot more to do here
  assert(Aggregator.put1(key, val))
end

function lagg:delete()
  assert(Aggregator.delete())
end

return lagg
