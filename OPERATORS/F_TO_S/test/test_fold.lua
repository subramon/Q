-- FUNCTIONAL
local Q = require 'Q'
local Scalar = require 'libsclr'
require 'Q/UTILS/lua/strict'
local tests = {}
tests.t1 = function()
  local len = 10000000
  local x, y, z 
  local c1 = Q.seq({start = 1, by = 1, len = len, qtype = "I4"})
  x, y, z = Q.fold({ "sum", "min", "max" }, c1)

  assert(type(x) == "Scalar") -- not Reducer 
  assert(type(y) == "Scalar") -- not Reducer 
  assert(type(z) == "Scalar") -- not Reducer 
  -- print(x:to_num())
  -- print(y:to_num())
  -- print(z:to_num())

  assert(x == Q.sum(c1):eval()) 
  assert(y == Q.min(c1):eval())
  assert(z == Q.max(c1):eval())
  print("Test t1 succeeded")
end
return tests
