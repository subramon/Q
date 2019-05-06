-- SANITY TEST
-- ## Problem: Sum of consecutive natural numbers & its reverse returns a constant array
-- ## Using Q.seq & Q.const to solve a problem

-- Library Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  -- Original Series
  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 1000} )
  -- Reverse Series
  local b = Q.seq( {start = 999, by = -1, qtype = "I4", len = 1000} )
  -- Sum of series
  local c = Q.vvadd(a, b)
  -- Expected Outcome
  local d = Q.const( { val = 1000, qtype = "I4", len = 1000 })
  -- Expected Outcome
  --========================================
  assert(Q.sum(Q.vveq(d, c)):eval():to_num() == 1000)
  --=======================================
end
--======================================
return tests
