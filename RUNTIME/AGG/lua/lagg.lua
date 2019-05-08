local ffi		= require 'Q/UTILS/lua/q_ffi'
local qconsts		= require 'Q/UTILS/lua/q_consts'
local cmem		= require 'libcmem'
local Scalar		= require 'libsclr'
local Agg		= require 'libagg'
local register_type	= require 'Q/UTILS/lua/q_types'
local qc		= require 'Q/UTILS/lua/q_core'
local get_ptr           = require 'Q/UTILS/lua/get_ptr'
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
  initial_size, keytype, valtype == parse_params(params)
  --==========================================
  agg._agg = assert(Agg.new(initial_size, keytype, valtype))
  agg._keytype  = keytype 
  agg._valtype  = valtype 
  if ( qconsts.debug ) then agg:check() end
  return agg
end

function lagg:delete()
  assert(Agg.delete())
end

return lagg
