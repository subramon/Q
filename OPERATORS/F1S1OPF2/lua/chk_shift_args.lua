local Scalar         = require 'libsclr'
local function chk_shift_args(qtype, scalar)
  assert( ( qtype == "I1" ) or ( qtype == "I2" ) or 
          ( qtype == "I4" ) or ( qtype == "I8" ) )
  local stype = scalar:fldtype()
  assert( ( stype == "I1" ) or ( stype == "I2" ) or 
          ( stype == "I4" ) or ( stype == "I8" ) )
  local sval = scalar:to_num()
  assert(sval >= 0)
  if ( qtype == "I1" ) then assert(sval <= 8 ) end 
  if ( qtype == "I2" ) then assert(sval <= 16 ) end 
  if ( qtype == "I4" ) then assert(sval <= 32 ) end 
  if ( qtype == "I8" ) then assert(sval <= 64 ) end 
  return sval
end
return  chk_shift_args
