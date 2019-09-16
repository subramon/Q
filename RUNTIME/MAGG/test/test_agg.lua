lAggregator = require 'Q/RUNTIME/MAGG/lua/lAggregator'

local tests = {}
tests.t1 = function(n)
  local n = n or 1000
  -- create an aggregator, should work
  local T1 = require 'Q/RUNTIME/MAGG/lua/test1'
  local A = lAggregator(T1, "libtest1.so", "test1")
  A:instantiate()
  for i = 1, n do
    A:put1(100+i, { 10, 20, 30, 40 })
  end
  print("Success on test t1")
  local M = A:meta()
  for k, v in pairs(M) do print(k, v) end 
end
-- return tests
tests.t1()
