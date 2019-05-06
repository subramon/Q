-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'

local tests = {}

tests.t1 = function ()
  local x = Q.mk_col({1, 2, -3, 4, -5, 6}, "I4")
  local y = Q.mk_col({1, -2, 3, -4, 5, 6}, "I4")
  local a, b = Q.vvpromote(x,y)
  assert(y == b)
  assert(x == a)
  print("Test t1 succeeded")
end
tests.t2 = function ()
  local x = Q.mk_col({1, 2, -3, 4, -5, 6}, "I1")
  local y = Q.mk_col({1, -2, 3, -4, 5, 6}, "I4")
  local a, b = Q.vvpromote(x,y)
  assert(y == b)
  assert(a:fldtype() == "I4")
  print("Test t2 succeeded")
end
-- TODO Write more tests
tests.t3 = function ()
  local x = Q.rand( { lb = 1000000, ub = 10000000, qtype = "I4", len = 1000000 })
  local y =Q.rand( { lb = 1000000, ub = 10000000, qtype = "I4", len = 1000000 })
  local a, b = Q.vvpromote(x,y)
  assert(y == b)
  assert(x == a)
  print("Test t3 succeeded")
end
tests.t4 = function ()
  local x = Q.rand( { lb = 1000000, ub = 10000000, qtype = "F4", len = 1000000 })
  local y =Q.rand( { lb = 1000000, ub = 10000000, qtype = "F8", len = 1000000 })
  local a, b = Q.vvpromote(x,y)
  assert(y == b)
  assert(a:fldtype() == "F8")
  assert(Q.sum(Q.vveq(a, x)):eval():to_num() == 1000000)
  print("Test t4 succeeded")
end
tests.t5 = function ()
  local len = 32767
  local x = Q.seq( {start = -1, by = -1, qtype = "I2", len = len} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = len} )
  local a, b = Q.vvpromote(x,y)
  assert(a:fldtype() == "I4")
  assert(Q.sum(Q.vveq(a,x)):eval():to_num() == len)
  print("Test t5 succeeded")
end
tests.t6 = function ()
  local len = 127
  local x = Q.seq( {start = -1, by = -1, qtype = "I1", len = len} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = len} )
  local a, b = Q.vvpromote(x,y)
  assert(a:fldtype() == "I4")
  Q.sort(a:eval(), "asc")
  Q.sort(b:eval(), "dsc")
  assert(Q.sum(Q.vvadd(a,b)):eval():to_num() == 0)
  print("Test t6 succeeded")
end
tests.t7 = function ()
  local len = 127
  local x = Q.seq( {start = -1, by = -1, qtype = "I1", len = 127} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I8", len = 127} )
  local a, b = Q.vvpromote(x,y)
  assert(a:fldtype() == "I8")
  Q.sort(a:eval(), "asc")
  local c = Q.abs(a)
  Q.sort(b:eval(), "dsc")
  assert(Q.sum(Q.vveq(b,c)):eval():to_num() == len)
  print("Test t7 succeeded")
end
return tests
