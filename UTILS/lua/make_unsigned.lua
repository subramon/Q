local function make_unsigned(qtype)
  assert(type(qtype) == "string")
  if ( qtype == "I1" )  then return "UI1" end 
  if ( qtype == "I2" )  then return "UI2" end 
  if ( qtype == "I4" )  then return "UI4" end 
  if ( qtype == "I8" )  then return "UI8" end 
  if ( qtype == "UI1" ) then return qtype end 
  if ( qtype == "UI2" ) then return qtype end 
  if ( qtype == "UI4" ) then return qtype end 
  if ( qtype == "UI8" ) then return qtype end 
  assert("Cannot make unsigned from " .. qtype)
end
return make_unsigned
