-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'

local tests = {}

tests.t1 = function ()
  local x = Q.mk_col({1, 2, 3, 4, 5}, "I4")
  local y = Q.mk_col({1, 2, 3, 4, 5}, "I4")
  assert(Q.vvseq(x, y, 0) == true)
  print("Test t1 succeeded")
end
--======================================
tests.t2 = function ()
  local x = Q.mk_col({1, 2, 3, 4, 5}, "I4")
  local y = Q.mk_col({2, 3, 4, 5, 6}, "I4")
  assert(Q.vvseq(x, y, 0) == false)
  print("Test t2 succeeded")
end
--======================================
tests.t3 = function ()
  local x = Q.mk_col({1, 2, 3, 4, 5}, "I4")
  local y = Q.mk_col({2, 3, 4, 5, 6}, "I4")
  assert(Q.vvseq(x, y, 1) == true)
  print("Test t3 succeeded")
end
--======================================
tests.t4 = function ()
  local x = Q.rand({ lb = 10, ub = 20, qtype = "F4", len = 65537 } )
  assert(Q.vvseq(x, Q.reciprocal(Q.reciprocal(x)), 0.01) == true)
  print("Test t4 succeeded")
end
--======================================
tests.t5 = function ()
  local qtypes = { "F4", "F8" }
  for _, qtype in ipairs(qtypes) do 
    local x = Q.rand({ lb = 1000000, ub = 2000000, qtype = qtype, len = 10 } )
    assert(Q.vvseq(x, Q.reciprocal(Q.reciprocal(x)), 0.01, { mode = "ratio"}) == true)
  end
  print("Test t5 succeeded")
end
--======================================
return tests
