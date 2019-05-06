-- FUNCTIONAL
local Q = require 'Q'
local qc      = require 'Q/UTILS/lua/q_core'

local tests = {}
tests.t1 = function()
  local len = 100000000
  local x, y, z
  local c0 = Q.seq({start = 1, by = 1, len = len, qtype = "I4"})
  local c1 = Q.seq({start = 1, by = 1, len = len, qtype = "I4"})
  c1:memo(false)
  local start_time = qc.RDTSC()
  x, y, z = Q.fold({ "sum", "min", "max" }, c1)

  assert(type(x) == "Scalar") -- not Reducer
  assert(type(y) == "Scalar") -- not Reducer
  assert(type(z) == "Scalar") -- not Reducer
  -- print(x:to_num())
  -- print(y:to_num())
  -- print(z:to_num())

  assert(x == Q.sum(c0):eval())
  assert(y == Q.min(c0):eval())
  assert(z == Q.max(c0):eval())
  local stop_time = qc.RDTSC()
  print("test_fold_memo_false", stop_time-start_time)
  print("Test t1 succeeded")
end
return tests

