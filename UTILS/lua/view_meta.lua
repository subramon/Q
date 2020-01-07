local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local json    = require 'Q/UTILS/lua/json'
local T = {}
local function view_meta ()
  local V = {}
  for k,v in pairs(_G) do
    if ( type(v) == "lVector" ) then 
      local x = v:meta()
      for k2, v2 in pairs(x) do 
        assert( ( ( k2 == "base" ) or ( k2 == "nn") or ( k2 == "aux" ) ))
        for k3, v3 in pairs(v2) do 
          if ( type(v3) == "Scalar") then 
            v2[k3] = v3:to_str()
          end
        end
      end
      V[k] = x
      -- print("Saving ", k, v)
    end
  end
  local jV = json.stringify(V)
  return V, jV
end
T.view_meta = view_meta
require('Q/q_export').export('view_meta', view_meta)
return T
