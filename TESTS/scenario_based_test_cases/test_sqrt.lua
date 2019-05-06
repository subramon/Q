-- luajit q_testrunner.lua $HOME/WORK/Q/TESTS/scenario_based_test_cases/test_sqrt.lua
-- SANITY TEST
-- ## Problem: Square a whole number and then take out its square root, the result must be same.
-- ## Using Q.seq & Q.sqrt to solve a problem

-- Library Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
	-- Creating a vector
	local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 10} )
	-- Creating another vector which is square of the vector a
	local b = Q.vvmul(a, a)
	-- Finding square root of the elements of the series b
	local c = Q.sqrt(b)
	-- Expected Outcome
	--========================================
	local result = Q.vveq(a, c)
	assert(Q.sum(result):eval():to_num() == 10)
  --=======================================
end
  --=======================================
return tests
