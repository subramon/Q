-- Test arithmetic behaviour of the operators of Q
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  -- Test that c = (a+b)/a
  local a = Q.mk_col({1, 2, 3}, "I4")
  local b = Q.mk_col({3, 2, 1}, "I4")
  local c = Q.mk_col({4, 2, 1}, "I4")
  local x = Q.vvdiv(Q.vvadd(a, b), a)
  assert(type(x) == "lVector")
  local y = Q.vveq(x, c)
  assert(type(y) == "lVector")
  assert(Q.sum(y):eval():to_num() == a:length())
end

--======================================

tests.t2 = function()
  --  test that a + b/a
  local a = Q.mk_col({1, 2, 3}, "I4")
  local b = Q.mk_col({3, 2, 1}, "I4")
  local d = Q.mk_col({4, 3, 3}, "I4")

  local x  = Q.vvadd(a, Q.vvdiv(b, a))
  assert(type(x) == "lVector")
  local y = Q.vveq(x, d)
  assert(type(y) == "lVector")
  assert(y:fldtype() == "B1")
  assert(Q.sum(y):eval():to_num() == a:length())
end

--======================================

return tests

