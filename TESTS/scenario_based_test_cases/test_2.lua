-- Scenario based testing
-- ## Problem: Validating sum of series

-- Libraray Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  -- Create vector 'a' with Q.rand or by Q.seq
  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 65000} )
  -- Create vector b of odd numbers through Q.seq
  local b = Q.seq( {start = 1, by = 2, qtype = "I4", len = 32500} )
  -- Create vector b of even numbers through Q.seq
  local c = Q.seq( {start = 2, by = 2, qtype = "I4", len = 32500} )
  -- ToDo: Boundary Condition seems to break beyond 65000 mark (approx)
  -- Finding sum of each vector elements
  local s1 = Q.sum(a):eval():to_num()
  local s2 = Q.sum(b):eval():to_num()
  local s3 = Q.sum(c):eval():to_num()
  -- Comparing data sets
  assert(s1 == s2 + s3)
end

--======================================

return tests
