local Q        = require 'Q'
local Scalar  = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local function lr_logit(x, no_memo)
  -- Given x, return 
  -- (1) y = 1/(1+e^(-1*x))
  -- (2) z = 1/((1+e^x)^2)

  assert(x)
  assert(type(x) == "lVector", "input must be a column")
  local fldtype = x:fldtype()
  assert( ( fldtype == "F4" ) or ( ( fldtype == "F8" ) ) )

  local t1 = Q.vsmul(x, Scalar.new(-1, fldtype)):memo(false):set_name("t1")
  local t2 = Q.exp(t1):memo(false):set_name("t2")
  local t3 = Q.incr(t2):memo(false):set_name("t3")
  local t4 = Q.sqr(t3):memo(false):set_name("t4")
  local y  = Q.reciprocal(t3):set_name("y")
  local z  = Q.reciprocal(t4):set_name("z")
  if ( no_memo ) then 
    y:memo(false)
    z:memo(false)
    return y, z
  end

  local cidx = 0  -- chunk index
  local len = 0
  local len2 = 0
  repeat 
    local ly  = y:chunk(cidx)
    local lz = z:chunk(cidx)
    assert(ly == lz)
    cidx = cidx + 1
  until ( ly == 0 )
  return y, z
end
return lr_logit
