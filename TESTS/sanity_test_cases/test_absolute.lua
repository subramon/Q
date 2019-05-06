-- SANITY TEST
-- ## Problem: Verifying the sum of opposite vector and the change when abs operator comes into play.
-- ## Using Q.seq & absolute function to solve a problem

-- Library Calls
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  -- Negative Series
  local a = Q.seq( {start = -100, by = 1, qtype = "I4", len = 100} )
  -- Positive Series
  local b = Q.seq( {start = 1, by = 1, qtype = "I4", len = 100} )
  -- Sort a
  Q.sort(a:eval(), "dsc")
  -- Vector Sum of sorted dsc a & b
  local c = Q.vvadd(a, b)
  assert(type(c) == "lVector")
  -- Expected Outcome
  assert(Q.sum(c):eval():to_num() == 0)
end

--=======================================

tests.t2 = function ()
  -- Negative Series
  local a = Q.seq( {start = -100, by = 1, qtype = "I4", len = 100} )
  -- Positive Series
  local b = Q.seq( {start = 1, by = 1, qtype = "I4", len = 100} )
  -- Apply abs function
  local c = Q.abs(a)
  assert(type(c) == "lVector")
  -- Vector Sum
  local d = Q.vvadd(c, b)
  assert(type(d) == "lVector")
  -- Expected Outcome
  assert(Q.sum(d):eval():to_num() == 2*Q.sum(b):eval():to_num())
end

--=======================================

return tests

