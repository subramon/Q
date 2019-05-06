local convert = (require "Q/OPERATORS/F1S1OPF2/lua/_f1s1opf2").convert
local promote = require "Q/UTILS/lua/promote"

local T = {} 
local function vvpromote(x, y)
 -- TODO P1 to be written

  assert(x and type(x) == "lVector")
  assert(y and type(y) == "lVector")
  if ( x:fldtype() == y:fldtype() ) then 
    return x, y
  end
  local newxtype = assert(promote(x:fldtype(), y:fldtype()))
  local newytype = assert(promote(y:fldtype(), x:fldtype()))
  return convert(x, newxtype), convert(y, newytype)
end
T.vvpromote = vvpromote
require('Q/q_export').export('vvpromote', vvpromote)
return T
