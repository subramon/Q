local qc		= require 'Q/UTILS/lua/q_core'
--====================================
local function parse_params(params)
  local initial_size, keytype, valtype
  assert(params)
  if  params.initial_size then 
    initial_size = params.initial_size 
    assert(type(params.initial_size) == "number")
    assert(initial_size >= 0)
  end

  keytype = params.keytype 
  assert(type(params.keytype) == "string")
  assert( ( keytype == "I4" ) or ( keytype == "I8" ) )

  valtype = params.valtype 
  assert(type(params.valtype) == "string")
  assert( ( valtype == "I1" ) or ( valtype == "I2" ) or
          ( valtype == "I4" ) or ( valtype == "I8" ) or
          ( valtype == "F4" ) or ( valtype == "F8" ) )


  return initial_size, keytype, valtype
end
return parse_params
