-- FUNCTIONAL
local Q = require 'Q'
local qc      = require 'Q/UTILS/lua/q_core'

local tests = {}
tests.t1 = function()
  local len = 100000000
  local x, y, z
  local c1 = Q.seq({start = 1, by = 1, len = len, qtype = "I4"})
  c1:eval()
  local start_time = qc.RDTSC()
  x = Q.sum(c1)
  y = Q.min(c1)
  z = Q.max(c1)

  assert(type(x) == "Reducer") -- not Reducer
  assert(type(y) == "Reducer") -- not Reducer
  assert(type(z) == "Reducer") -- not Reducer

  assert(x:eval())
  assert(y:eval())
  assert(z:eval())
  local stop_time = qc.RDTSC()
  print("test_sum_min_max", stop_time - start_time)
  print("Test t1 succeeded")
end

return tests
