local ffi = require 'ffi'

local function get_activation_functions(params, nl)
  assert(type(params) == "table", "dnn constructor requires table as arg")
  local afns = {}
  if ( not params.activation_functions ) then 
    afns[1] = "NONE"
    for i = 2, nl do 
      afns[i] = "sigmoid"
    end
  else
    afns = params.activation_functions
    assert( ( type(afns) == "table" ) and ( #(afns)  == nl) )
    local n = 0
    for k, v in ipairs(afns) do 
      assert(type(v) == "string")
      if ( k ~= 1 ) then assert(#v > 0) end 
      n = n + 1 
    end 
    afns[1] = "NONE"
    assert(n == nl)
  end
  afns = table.concat(afns, ":")
  return afns
end
return get_activation_function
