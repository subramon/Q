local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
for i = 1,1000 do
  local c1 = Q.mk_col({1, 9, 2, 8, 3, 7}, "I4")
  local c2 = Q.mk_col({7, 1, 3, 2, 1, 0}, "I4")
  local z = Q.vvmul(c1, c2)
  assert(type(z) == "lVector", "Z NOT lVector WRONG")
  local s = Q.sum(z)
  assert(type(s:eval()) == "Scalar", "S NOT SCALAR WRONG")
  local val = s:eval():to_num() 
  assert(val == 41, "WRONG, val = " .. val)
end
end
--======================================
tests.t2 = function ()

for i = 1,1000 do
  local c1 = Q.rand({ lb = 10, ub = 20, seed = 1234, qtype = "F4", len = 65537 } )
  local c2 = Q.rand({ lb = 10, ub = 20, seed = 1234, qtype = "F4", len = 65537 } )
  local z = Q.vvmul(c1, c2)
  assert(type(z) == "lVector", "Z NOT lVector WRONG")
  local s = Q.sum(z)
  assert(type(s:eval()) == "Scalar", "S NOT SCALAR WRONG")
  local val = s:eval() 
  local w = Q.vvmul(c1, c1)
  w:eval()
end

end
--======================================
return tests
