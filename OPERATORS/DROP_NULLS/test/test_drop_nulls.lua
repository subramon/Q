-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local Scalar = require 'libsclr' ; 

local tests = {}
tests.t1 = function()
  local x = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, "I4")
  local y = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "B1")
  local sval = Scalar.new("100", "I4")
  x:make_nulls(y)
  print("XXXXXXXXX TODO FAILING")
  local z = Q.drop_nulls(x, sval)
  print("YYYYYYYYY")
  assert(Q.sum(z):eval():to_num() == 316)
  print("Test t1 succeeded")
end
return tests
