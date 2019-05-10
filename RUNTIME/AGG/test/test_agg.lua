lAggregator = require 'Q/RUNTIME/AGG/lua/lagg'

local tests = {}
tests.t1 = function()
  local params = { initial_size = 1024, keytype = "I4", valtype = "I4"}
  local x = lAggregator(params)
end
tests.t1()
-- return tests
