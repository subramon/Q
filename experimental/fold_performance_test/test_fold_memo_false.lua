-- FUNCTIONAL
local Q = require 'Q'
local qc      = require 'Q/UTILS/lua/q_core'

local tests = {}
tests.t1 = function()
  local len = 100000000
  local x, y, z
  local c1 = Q.seq({start = 1, by = 1, len = len, qtype = "I4"})
  c1:memo(false)
  local start_time = qc.RDTSC()
  x, y, z = Q.fold({ "sum", "min", "max" }, c1)

  assert(type(x) == "Scalar") -- not Reducer
  assert(type(y) == "Scalar") -- not Reducer
  assert(type(z) == "Scalar") -- not Reducer

  local stop_time = qc.RDTSC()
  print("test_fold_memo_false", stop_time-start_time)
  print("Test t1 succeeded")
  os.exit()
end
return tests

