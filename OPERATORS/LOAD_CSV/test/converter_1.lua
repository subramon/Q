local function conv(x)
  assert(type(x) == "string")
  if ( x == "Sunday" )   then return 1 end 
  if ( x == "Monday" )   then return 2 end 
  if ( x == "Tuesday" )  then return 3 end 
  if ( x == "Wednesday" )then return 4 end 
  if ( x == "Thursday" ) then return 5 end 
  if ( x == "Friday" )   then return 6 end 
  if ( x == "Saturday" ) then return 7 end 
  if ( x == "XXXXXXX" ) then return 8 end 
  error(x)
end
return conv
