lAggregator = require 'Q/RUNTIME/MAGG/lua/lAggregator'

local tests = {}
tests.t1 = function()
  -- create an aggregator, should work
  local T1 = require 'Q/RUNTIME/MAGG/lua/test1'
  local x = lAggregator(T1, "libtest1.so", "test1")
  print("Success on test t1")
end
-- return tests
tests.t1()
