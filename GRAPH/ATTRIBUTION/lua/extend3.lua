local Q = require 'Q'
local Scalar = require 'libsclr'

local function extend(inT, y0)
  assert(type(inT) == "table")
  local xk = inT.x
  local yk = inT.y
  assert(type(xk) == "lVector")
  assert(type(yk) == "lVector")
  assert(type(y0) == "lVector")
  --========================================
  local T = {}
  local szero = Scalar.new(0, "I1")

  xk:set_name("xk")
  yk:set_name("yk")
  local z = Q.get_val_by_idx(yk, y0):memo(false):set_name("z")
  local y, i = Q.vsgeq_val(z, szero)
  y:set_name("y")
  i:set_name("i")
  i:memo(false)

  xk:eval()
  local x = Q.get_val_by_idx(i, xk)
  x:set_name("x")
  x:eval()

  T.x = x; T.y = y;
  return T
end
return extend

