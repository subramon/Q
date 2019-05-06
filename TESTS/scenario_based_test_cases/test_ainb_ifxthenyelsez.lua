-- luajit q_testrunner.lua $HOME/WORK/Q/TESTS/scenario_based_test_cases/test_ainb_ifxthenyelsez.lua
-- Scenario based testing
-- ## Using ainb & ifxthenyelsez to solve a problem
-- ## Let b is the expected sample space
-- ## Let a be the sampling space as created by data collector through a survey
-- ## Let the payment be $ 100 for each correct data collected and $ 50 for each data collected that do not meet the expectations.
-- ## Problem: To calculate the success rate of the survey and cost of the survey.

-- Libraray Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  -- Expected data sample space
  local b = Q.mk_col({97.4, 94, 99.3, 92.5 }, "F4")
  -- Collected data sample space
  local a = Q.mk_col({87.3, 99.6, 99, 10, 92.5, 50, 99.3, 97.4, 90, 95}, "F4")
  -- Mapping data collected on expected
  local x = Q.ainb(a, b)
  -- Verifying outcome
  assert(Q.sum(x:eval()):eval():to_num() == 3)
  -- payment matrix
  local y = Q.const( { val = 100, qtype = 'I4', len = 10} )
  local z = Q.const( { val = 50, qtype = 'I4', len = 10} )
  -- expected expense sheet of the survey
  local exp_r = Q.mk_col({50,50,50,50,100, 50, 100, 100, 50, 50 }, "I4")
  -- calculate expense as per the mapping
  local r = Q.ifxthenyelsez(x, y, z)
  --print("The expense on conducting the survey is $",Q.sum(r):eval():to_num())
  assert(Q.sum(Q.vveq(r, exp_r)):eval():to_num() == 10)
end
--======================================
return tests

