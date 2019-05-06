-- Testing where operator
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  local a = Q.rand( { lb = 10, ub = 25, qtype = "F4", len = 10 })
  a:eval()
  local b = Q.mk_col({1, 0, 0, 1, 0, 1, 1, 0, 0, 0}, "B1")
  --local out_table = {10, 40}
  local c = Q.where(a, b)
  assert(c:eval():length() == Q.sum(b):eval():to_num(), "Length Mismatch")
end

--======================================

tests.t2 = function ()
  local a = Q.rand( { lb = 10, ub = 25, qtype = "F4", len = 10 })
  a:eval()
  local b = Q.mk_col({1, 1, 1, 1, 1, 1, 1, 1, 1, 1}, "B1")
  local c = Q.where(a, b)
  assert(Q.sum(a):eval():to_num() == Q.sum(c):eval():to_num(), "Sum Mismatch")
  assert(Q.min(a):eval():to_num() == Q.min(c):eval():to_num(), "Min Mismatch")
  assert(Q.max(a):eval():to_num() == Q.max(c):eval():to_num(), "Max Mismatch")
end

--======================================

tests.t3 = function ()
  local a = Q.rand( { lb = 10, ub = 25, qtype = "F4", len = 10 })
  a:eval()
  -- Expected data sample space
  local q = Q.mk_col({97.4, 94, 99.3, 92.5 }, "F4")
  -- Collected data sample space
  local p = Q.mk_col({87.3, 99.6, 99, 10, 92.5, 50, 99.3, 97.4, 90, 95}, "F4")
  -- Mapping data collected on expected
  local r = Q.ainb(p, q)
  r:eval()
  local s = Q.where(a,r)
  assert(s:eval():length() == Q.sum(r):eval():to_num(), "Length Mismatch")
end

--======================================

return tests







