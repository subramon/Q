local Q = require 'Q'
local Scalar = require 'libsclr'

local tests = {}

-- Q.mul should call Q.vvmul
tests.t1 = function()
  local col_1 = Q.mk_col({10, 20, 30}, "I2")
  local col_2 = Q.mk_col({10, 20, 30}, "I2")
  local res = Q.mul(col_1, col_2)
  assert(res)
  local sum = Q.sum(res):eval():to_num()
  assert(sum == 1400)
  print("Completed test t1")
end

-- Q.mul should call Q.vsmul
tests.t2 = function()
  local col_1 = Q.mk_col({10, 20, 30}, "I2")
  local s_val = Scalar.new(10, "I2")
  local res = Q.mul(col_1, s_val)
  assert(res)
  local sum = Q.sum(res):eval():to_num()
  assert(sum == 600)
  print("Completed test t2")
end

return tests