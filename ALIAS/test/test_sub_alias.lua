local Q = require 'Q'
local Scalar = require 'libsclr'

local tests = {}

-- Q.sub should call Q.vvsub
tests.t1 = function()
  local col_1 = Q.mk_col({100, 200, 300}, "I2")
  local col_2 = Q.mk_col({50, 150, 250}, "I2")
  local res = Q.sub(col_1, col_2)
  assert(res)
  local sum = Q.sum(res):eval():to_num()
  assert(sum == 150)
  print("Completed test t1")
end

-- Q.sub should call Q.vssub
tests.t2 = function()
  local col_1 = Q.mk_col({100, 200, 300}, "I2")
  local s_val = Scalar.new(50, "I2")
  local res = Q.sub(col_1, s_val)
  assert(res)
  local sum = Q.sum(res):eval():to_num()
  assert(sum == 450)
  print("Completed test t2")
end

return tests