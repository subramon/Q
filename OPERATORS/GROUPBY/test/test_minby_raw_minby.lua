local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  -- validating raw_minby to return min value from value vector
  -- according to the given grpby vector
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I4")
  local b = Q.mk_col({0, 1, 0, 1, 1, 0, 0, 1}, "I1")
  local exp_val = {1, 2}
  local nb = 2
  local res = Q.raw_minby(a, b, nb)
  res:eval()
  -- verify
  assert(res:length() == nb)
  assert(res:length() == #exp_val)
  assert(res:meta().aux.has_nulls == nil)
  local val, nn_val
  for i = 1, res:length() do
    val, nn_val = res:get_one(i-1)
    assert(val:to_num() == exp_val[i])
  end
  print("Test t1 completed")
end

tests.t2 = function()
  -- as grpby 0th value doesn't have respective values in value vector
  -- testing Q.minby to return result vector along with nulls
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I2")
  local b = Q.mk_col({1, 1, 3, 1, 1, 2, 1, 2}, "I2")
  local expected_result = "\n1\n7\n"
  local nb = 3
  local res = Q.minby(a, b, nb, {is_safe = false})
  res:eval()
  -- verify
  assert(res:length() == nb)
  -- this check will fail as res col has_nulls in it
  -- assert(res:length() == #exp_val)
  assert(res:meta().aux.has_nulls == true)
  local actual_result = Q.print_csv(res, { opfile = "" })
  assert(actual_result == expected_result)
  print("Test t2 completed")
end

tests.t3 = function()
  -- as grpby 2th value doesn't have respective values in value vector
  -- testing Q.minby to return result vector along with nulls
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I2")
  local b = Q.mk_col({1, 0, 0, 1, 1, 0, 1, 1}, "I2")
  local expected_result = "2\n1\n\n"
  local nb = 3
  local res = Q.minby(a, b, nb, {is_safe = false})
  res:eval()
  -- verify
  assert(res:length() == nb)
  assert(res:meta().aux.has_nulls == true)
  local actual_result = Q.print_csv(res, { opfile = "" })
  assert(actual_result == expected_result)
  print("Test t3 completed")
end

return tests