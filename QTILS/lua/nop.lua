local T = {}
local function nop(x)
  if ( x  and (type(x) == "string" ) ) then 
    print(x)
  else
    print("nop failed")
  end
end
T.nop = nop
require('Q/q_export').export('nop', nop)
return T
