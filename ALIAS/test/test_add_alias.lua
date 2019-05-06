local Q = require 'Q'
local Scalar = require 'libsclr'

local tests = {}

-- Q.add should call Q.vvadd
tests.t1 = function()
  local col_1 = Q.mk_col({10, 20, 30}, "I1")
  local col_2 = Q.mk_col({10, 20, 30}, "I1")
  local res = Q.add(col_1, col_2)
  assert(res)
  local sum = Q.sum(res):eval():to_num()
  assert(sum == 120)
  print("Completed test t1")
end

-- Q.add should call Q.vsadd
tests.t2 = function()
  local col_1 = Q.mk_col({10, 20, 30}, "I1")
  local s_val = Scalar.new(10, "I1")
  local res = Q.add(col_1, s_val)
  assert(res)
  local sum = Q.sum(res):eval():to_num()
  assert(sum == 90)
  print("Completed test t2")
end

return tests