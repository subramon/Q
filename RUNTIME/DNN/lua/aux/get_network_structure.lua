local ffi = require 'ffi'
local cmem		= require 'libcmem'
local get_ptr           = require 'Q/UTILS/lua/get_ptr'
 --==========================================
local function get_network_structure(params)
  assert( ( params.npl) and 
            ( type(params.npl) == "table" ) and 
            ( #(params.npl) >= 1 ) )
  local nl  = #params.npl-- number  of layers
  local npl = params.npl -- neurons per layers 
  local X -- temporary variable
  --
  -- c_npl = C neurons per layer 
  assert(nl >= 3)
  local c_npl = cmem.new(ffi.sizeof("int") * nl, "I4", "npl") 
  assert(c_npl)
  X = get_ptr(c_npl, "I4")
  for i = 1, nl do 
    assert(npl[i] > 0)
    X[i-1] = npl[i] -- Lua index by 1, C by 0
  end
  return nl, npl, c_npl
end
--=====================================================
return get_network_structure
