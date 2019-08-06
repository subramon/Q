local ffi = require 'ffi'
local cmem		= require 'libcmem'
local get_ptr           = require 'Q/UTILS/lua/get_ptr'

local function get_dropout_per_layer(params, nl)
  assert(params and ( type(params) == "table" ) )
  local dpl = {}
  for i = 1, nl do 
    dpl[i] = 0
  end
  if ( params.dpl ) then 
    dpl = params.dpl
    assert(type(dpl) == "table") 
    assert(#dpl == nl)
    for i = 1, nl do 
      assert(type(dpl[i] ) == "number")
      assert( ( (dpl[i] >= 0 ) and (dpl[i] < 1 ) ) )
    end
  end
  local c_dpl = cmem.new(ffi.sizeof("float") * nl, "F4", "dpl") 
  assert(c_dpl)
  local  X = get_ptr(c_dpl, "F4")
  for i = 1, nl do 
    X[i-1] = dpl[i]
  end
  return dpl, c_dpl
end
return get_dropout_per_layer
