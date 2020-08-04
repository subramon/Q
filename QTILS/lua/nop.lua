local T = {}
local function internal_nop(x)
  if ( x  and (type(x) == "string" ) ) then 
    print(x)
  else
    print("nop failed")
  end
  return true
end
local function nop(x)
  local status, col = pcall(internal_nop, x)
  if ( not status ) then print col end 
  return col 
end
T.nop = nop
require('Q/q_export').export('nop', nop)
return T
