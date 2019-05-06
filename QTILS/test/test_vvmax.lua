-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'

local tests = {}

tests.t1 = function ()
  local x = Q.mk_col({1, 2, -3, 4, -5, 6}, "I4")
  local y = Q.mk_col({1, -2, 3, -4, 5, 6}, "I4")
  local z = Q.mk_col({1, 2, 3, 4, 5, 6}, "I4")
  local t1 = Q.vvmax(x,y)
  assert(type(t1) == "lVector")
  assert(Q.sum(Q.vvneq(Q.vvmax(x, y), z)):eval():to_num() == 0 )
  -- t1:eval()
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(t1, opt_args)
  -- Q.print_csv(Q.vvmax(x,y):eval(), opt_args)
  print("Test t1 succeeded")
end
--=======================================
tests.t2 = function ()
  local x = Q.rand( { lb = 1000000, ub = 10000000, qtype = "I4", len = 1000000 })
  local y = Q.rand( { lb = 1000000, ub = 10000000, qtype = "I4", len = 1000000 })
  local t2 = Q.vvmax(x,y)
  assert(type(t2) == "lVector")
  assert(2*Q.sum(t2):eval():to_num() >= Q.sum(x):eval():to_num() + Q.sum(y):eval():to_num())
  print("Test t2 succeeded")
end
--=======================================
tests.t3 = function ()
  local x = Q.seq( {start = -1, by = -1, qtype = "I4", len = 1000000} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = 1000000} )
  local t3 = Q.vvmax(x,y)
  assert(type(t3) == "lVector")
  assert(Q.sum(Q.vveq(Q.vvmax(x, y), y)):eval():to_num() == 1000000 )
  print("Test t3 succeeded")
end
--=======================================
tests.t4 = function ()
  local x = Q.seq( {start = -1, by = -1, qtype = "I4", len = 10000000} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = 10000000} )
  local t4 = Q.vvmax(x,y)
  assert(type(t4) == "lVector")
  assert(Q.sum(Q.vveq(Q.vvmax(x, y), Q.abs(x))):eval():to_num() == 10000000 )
  print("Test t4 succeeded")
end
--=======================================
return tests
