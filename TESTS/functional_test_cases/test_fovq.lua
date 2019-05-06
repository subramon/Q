-- Test arithmetic operators of Q
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  -- TEST FUNDAMENTAL OPERATION OF ADD
  local a = Q.mk_col({1, 2, 3}, "I4")
  local b = Q.mk_col({1, 2, 3}, "I4")
  local c = Q.mk_col({2, 4, 6}, "I4")
  local x = Q.vvadd(a, b)
  assert(type(x) == "lVector")
  local y = Q.vveq(x, c)
  assert(type(y) == "lVector")
  local sum = 
  assert(Q.sum(y):eval():to_num() == a:length())
end

--=======================================

tests.t2 = function ()
  -- TEST FUNDAMENTAL OPERATION OF SUBTRACT
  local a = Q.mk_col({1, 2, 3}, "I4")
  local b = Q.mk_col({1, 2, 3}, "I4")
  local c = Q.mk_col({0, 0, 0}, "I4")
  local x = Q.vvsub(a, b)
  assert(type(x) == "lVector")
  local y = Q.vveq(x, c)
  assert(type(y) == "lVector")
  assert(Q.sum(y):eval():to_num() == a:length())
end

--=======================================

tests.t3 = function()
  -- TEST FUNDAMENTAL OPERATION OF MULTIPLY
  local a = Q.mk_col({1, 2, 3}, "I4")
  local b = Q.mk_col({1, 2, 3}, "I4")
  local c = Q.mk_col({1, 4, 9}, "I4")
  local x = Q.vvmul(a, b)
  assert(type(x) == "lVector")
  local y = Q.vveq(x, c)
  assert(type(y) == "lVector")
  assert(Q.sum(y):eval():to_num() == a:length())
end

--=======================================

tests.t4 = function ()
  -- TEST FUNDAMENTAL OPERATION OF DIVIDE
  local a = Q.mk_col({1, 2, 3}, "I4")
  local b = Q.mk_col({1, 2, 3}, "I4")
  local c = Q.mk_col({1, 1, 1}, "I4")
  local x = Q.vvdiv(a, b)
  assert(type(x) == "lVector")
  local y = Q.vveq(x, c)
  assert(type(y) == "lVector")
  assert(Q.sum(y):eval():to_num() == a:length())
end

--=======================================

return tests







