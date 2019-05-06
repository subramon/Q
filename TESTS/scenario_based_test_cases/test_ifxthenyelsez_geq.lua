-- Scenario based testing
-- ## Problem: If data elelment in set greater than elements in set b
-- ## Using geq & ifxthenyelsez to solve a problem
-- ## Let a and b be data set
-- ## comparing the data set, if a > b assign value 1 or else 0.

-- Libraray Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
	-- Data set
	local a = Q.rand( { lb = 10, ub = 20, qtype = "I4", len = 10 })
	local b = Q.rand( { lb = 10, ub = 20, qtype = "I4", len = 10 })
	-- Comparing data sets
	local x = Q.vvgeq(a, b)
	-- value set
	local y = Q.const( { val = 1, qtype = 'I4', len = 10} )
	local z = Q.const( { val = 0, qtype = 'I4', len = 10} )
	-- applying logic
	local w = Q.ifxthenyelsez(x, y, z)
	--print("Number of elements in data set 'a' greater than in data set 'b' is", Q.sum(w):eval():to_num())
end
  --=======================================
return tests
