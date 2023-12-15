local Scalar = require 'libsclr'
local function from_scalar(x)
  if ( ( type(x) == "number") or 
       ( type(x) == "boolean" ) or 
       ( type(x) == "string" ) ) then
       return x
  end
  assert(type(x) == "Scalar")
  local qtype = x:qtype()
  if ( ( qtype == "I1" ) or ( qtype == "I2" ) or 
       ( qtype == "I4" ) or ( qtype == "I8" ) or 
       ( qtype == "UI1" ) or ( qtype == "UI2" ) or 
       ( qtype == "UI4" ) or ( qtype == "UI8" ) or 
       ( qtype == "F4" ) or ( qtype == "F8" ) ) then
    return x:to_num()
  elseif ( qtype == "SC" ) then 
    return x:to_str()
  elseif ( qtype == "BL" ) then
    return x:to_bool()
  else
    error("bad scalar type " ..  qtype)
  end
end
return from_scalar
