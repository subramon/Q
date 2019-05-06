local Q = require 'Q'
local function extend(inT, y0)
  assert(type(inT) == "table")
  local xk = inT.x
  local yk = inT.y
  assert(type(xk) == "lVector")
  assert(type(yk) == "lVector")
  assert(type(y0) == "lVector")
  --========================================
  local T = {}
  xk:set_name("xk")
  yk:set_name("yk")
  local z = Q.get_val_by_idx(yk, y0):memo(false):set_name("z")
  local w = Q.vsgeq(z, 0):memo(false):set_name("w")
  local x = Q.where(xk, w):memo(false):set_name("x")
  local y = Q.where(z, w):memo(false):set_name("y")
  cidx = 0
  repeat 
    print("cidx = ", cidx)
    local lz = z:chunk(cidx) 
    if ( lz == 0 ) then break end 
    print("++++ w ++++++")
    w:chunk(cidx)
    print("++++ x ++++++")
    x:chunk(cidx)
    print("++++ y ++++++")
    y:chunk(cidx)
    cidx = cidx + 1 
  until false
  print("=============")
  T.x = x; T.y = y; return T
end
return extend
