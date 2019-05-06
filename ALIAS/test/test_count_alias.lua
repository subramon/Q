local Q = require 'Q'
local Scalar = require 'libsclr'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local tests = {}

-- Q.count should call Q.unique, which will return 2 vectors
-- unique_vec and count_vec of same length
tests.t1 = function()
  local col_1 = Q.mk_col({1, 2, 3, 4, 4, 5, 6, 6, 6}, "I1")
  local unq, cnt = Q.count(col_1)
  assert(type(unq) ==  "lVector" and type(cnt) == "lVector")
  unq:eval()
  assert(unq:length() == 6 and cnt:length() == 6, "Incorrect length returned")
  -- Q.print_csv(unq)
  print("Completed test t1")
end

-- Q.count should call Q.count, which will return 'I8' scalar
tests.t2 = function()
  local col_1 = Q.mk_col({1, 2, 3, 4, 4, 5, 6, 6, 6}, "I1")
  local num = 4
  local res = Q.count(col_1, num)
  assert(type(res) == "Reducer")
  assert(res:eval():to_num() == 2, "Incorrect count returned")
  print("Completed test t2")
end

-- Q.count should call Q.count, which will return 'I8' scalar
tests.t3 = function()
  local col_1 = Q.mk_col({1, 2, 3, 4, 4, 5, 6, 6, 6}, "I1")
  local s_val = Scalar.new(6, "I1")
  local res = Q.count(col_1, s_val)
  assert(type(res) == "Reducer")
  assert(res:eval():to_num() == 3, "Incorrect count returned")
  print("Completed test t3")
end

tests.t4 = function ()
  local out_table = {10, 20, 30}
  local cnt_table = {4, 2, 3}
  local sum_table = {2, 1, 3}
  local a = Q.mk_col({10, 10, 10, 10, 20, 20, 30, 30, 30}, "I4")
  local a_B1 = Q.mk_col({1, 0, 1, 0, 1, 0, 1, 1, 1}, "B1")
  local c, d, e = Q.count(a, a_B1)
  c:eval()
  assert(d:is_eov() == true)
  assert(c:length() == #out_table)
  assert(d:length() == #cnt_table)
  Q.print_csv({c, d, e})
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == out_table[i])

    value = c_to_txt(d, i)

    assert(value == cnt_table[i])

    value = c_to_txt(e, i)
    assert(value == sum_table[i])
  end
  print("Test t15 succeeded")
end

return tests