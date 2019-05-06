-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
  tests.t1 = function()
  local c1 = Q.mk_col( {1,1,1,1}, "I4")
  local c2 = Q.cast(c1, "B1")
  local n1, n2 = Q.sum(c1):eval()
  assert(c1:fldtype() == "B1")
  assert(c1 == c2)
  assert(type(n1) == "Scalar")
  assert(type(n2) == "Scalar")
  assert(n1:to_num() == 4)
  assert(n2:to_num() == 4*32)
  
  local c1 = Q.mk_col( {3,3,3,3}, "I4")
  local c2 = Q.cast(c1, "B1")
  local n1, n2 = Q.sum(c1):eval()
  assert(n1:to_num() == 4*2)
  assert(n2:to_num() == 4*32)
end
--=======================================
return tests
