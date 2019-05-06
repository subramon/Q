-- Scenario based testing
-- ## Problem: Find out how many credit cards have interest rate lower than the search call.
-- ## Using leq & ifxthenyelsez to solve a problem
-- ## Let cc be the list of credit card by name
-- ## comparing the data set, if a > b assign value 1 or else 0.

-- Libraray Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
	-- Data set
	--ToDo -- cc = {list of credit cards} 
	local a = Q.rand( { lb = 8, ub = 30, qtype = "F4", len = 100 })
	local b = Q.const( { val = 14.25, qtype = "F4", len = 100 })
	-- Comparing data sets
	local x = Q.vvleq(a, b)
	-- value set
	local y = Q.const( { val = 1, qtype = 'I4', len = 100} )
	local z = Q.const( { val = 0, qtype = 'I4', len = 100} )
	-- applying logic
	local w = Q.ifxthenyelsez(x, y, z)
  --print("Number of credit cards searched whose interest rate percentage is less than 14.25 are", Q.sum(w):eval():to_num() )
end
--======================================
return tests
