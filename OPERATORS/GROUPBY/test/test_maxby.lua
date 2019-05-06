local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  -- validating maxby to return max value from value vector
  -- according to the given grpby vector
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I4")
  local b = Q.mk_col({0, 1, 0, 1, 1, 0, 1, 1}, "I1")
  local exp_val = {7, 9}
  local nb = 2
  local res = Q.maxby(a, b, nb)
  res:eval()
  -- verify
  assert(res:length() == nb)
  assert(res:length() == #exp_val)
  local val, nn_val
  for i = 1, res:length() do
    val, nn_val = res:get_one(i-1)
    val, nn_val = res:get_one(i-1)
    val, nn_val = res:get_one(i-1)
    assert(val:to_num() == exp_val[i])
  end
  print("Test t1 completed")
end

tests.t2 = function()
  -- maxby test in safe mode by setting is_safe to true
  -- group by column exceeds limit
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I4")
  local b = Q.mk_col({0, 1, 4, 1, 1, 2, 0, 2}, "I2")
  local nb = 3
  local status, res = pcall(Q.minby, a, b, nb, {is_safe = true})
  assert(status == false)
  print("Test t2 completed")
end

tests.t3 = function()
  -- maxby test in unsafe mode by setting is_safe to false
  -- grpby exceeds nb limit
  -- Values of b, not having 0
  -- this will write to wrong index(ie 0th index) by C code in out_buf
  -- result: it will work at times or will give a seg-fault
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I2")
  local b = Q.mk_col({1, 1, 3, 1, 1, 2, 1, 2}, "I2")
  local exp_val = {-32768, 8, 9}
  local nb = 3
  local res = Q.maxby(a, b, nb, {is_safe = false})
  res:eval()
  -- verify
  assert(res:length() == nb)
  assert(res:length() == #exp_val)
  local val, nn_val
  for i = 1, res:length() do
    val, nn_val = res:get_one(i-1)
    assert(val:to_num() == exp_val[i])
  end
  print("Test t3 completed")
end

tests.t4 = function()
  -- grpby not exceeding nb
  -- Values of b, not having 0
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I2")
  local b = Q.mk_col({1, 1, 2, 1, 1, 2, 1, 2}, "I2")
  -- the default value for 0th grpby will be the qtype max value
  -- if grpby does not respective values in value vector
  local exp_val = {-32768, 8, 9}
  local nb = 3
  local res = Q.maxby(a, b, nb)
  res:eval()
  -- verify
  assert(res:length() == nb)
  assert(res:length() == #exp_val)
  local val, nn_val
  for i = 1, res:length() do
    val, nn_val = res:get_one(i-1)
    assert(val:to_num() == exp_val[i])
  end
  print("Test t4 completed")
end

return tests
