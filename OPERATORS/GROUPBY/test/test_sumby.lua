local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I4")
  local b = Q.mk_col({0, 1, 2, 1, 1, 2, 0, 2}, "I2")
  local exp_val = {9, 13, 20}
  local nb = 3
  local res = Q.sumby(a, b, nb, {is_safe = true})
  assert(type(res) == "Reducer")
  local vres = res:eval()
  assert(type(vres) == "lVector")
  -- vefiry
  assert(vres:length() == nb)
  assert(vres:length() == #exp_val)
  local val, nn_val
  for i = 1, vres:length() do
    val, nn_val = vres:get_one(i-1)
    assert(val:to_num() == exp_val[i])
  end
  print("Test t1 completed")
end

tests.t2 = function()
  -- sumby test in safe mode ( default is safe mode )
  -- group by column exceeds limit
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I4")
  local b = Q.mk_col({0, 1, 4, 1, 1, 2, 0, 2}, "I2")
  local nb = 3
  local res = Q.sumby(a, b, nb)
  local status = pcall(res.eval, res)
  assert(status == false)
  print("Test t2 completed")
end

tests.t3 = function()
  -- Values of b, not having 0
  local a = Q.mk_col({1, 2, 4, 5, 6, 7, 8, 9}, "I4")
  local b = Q.mk_col({1, 1, 2, 1, 1, 2, 1, 2}, "I2")
  local exp_val = {0, 22, 20}
  local nb = 3
  local res = Q.sumby(a, b, nb)
  local vres = res:eval()

  -- vefiry
  assert(vres:length() == nb)
  assert(vres:length() == #exp_val)
  local val, nn_val
  for i = 1, vres:length() do
    val, nn_val = vres:get_one(i-1)
    assert(val:to_num() == exp_val[i])
  end

  print("Test t3 completed")
end


tests.t4 = function()
  -- Length of input vector more than chunk size
  -- note that len must be a mutlple of period  for this test
  local len = qconsts.chunk_size * 2 + 655
  local period = 3
  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = len} )
  local b = Q.period({ len = len, start = 0, by = 1, period = period, qtype = "I4"})
  local value = len/period
  local exp_sum = period*(value*(value+1)/2)
  local exp_val = {exp_sum-(value+value), exp_sum-value, exp_sum}
  local nb = 3

  local res = Q.sumby(a, b, nb)
  local vres = res:eval()

  assert(vres:length() == nb)
  local val, nn_val
  for i = 1, vres:length() do
    val, nn_val = vres:get_one(i-1)
    assert(val:to_num() == exp_val[i])
  end
  print("Test t4 completed")
end
tests.t5 = function()
  local len = qconsts.chunk_size * 2 + 7491
  local period = 3
  local nb = 3
  local p = 0.5

  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = len} )
  local b = Q.period({ len = len, start = 0, by = 1, period = period, qtype = "I4"})
  local c = Q.const( { val = true, qtype = "B1", len = len })
  -- local c = Q.rand( { probability = p, qtype = "B1", len = len })

  -- TODO local res = Q.sumby(a, b, nb, { where = c })
  local res = Q.sumby(a, b, nb)
  local vres = res:eval()

  assert(vres:length() == nb)
  local val, nn_val
  for i = 1, vres:length() do
    local act_val, nn_val = vres:get_one(i-1)
    local exp_val, n2 = Q.sum(Q.where(a, Q.vvand(c, Q.vseq(b, i-1)))):eval()
    -- print("i/actual/expected", i, act_val:to_num(), exp_val:to_num())
    assert(act_val:to_num() == exp_val:to_num())
  end
  print("Test t5 completed")
end

return tests
