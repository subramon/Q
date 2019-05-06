local Q = require 'Q'

local tests = {}

tests.t1 = function()
  local len = 65675
  local in_table = {}
  local exp_table = {}
  for i = 1, len do
    if i % 2 == 0 then
      in_table[i] = 1
      exp_table[i] = 0
    else
      in_table[i] = 0
      exp_table[i] = 1
    end
  end
  local col = Q.mk_col(in_table, "B1")
  local n_col = Q.vnot(col)
  n_col:eval()

  local val, nn_val
  for i = 1, n_col:length() do
    val, nn_val = n_col:get_one(i-1)
    assert(val:to_num() == exp_table[i], "Index: " .. tostring(i) .. 
      ", Expected: " .. tostring(exp_table[i]) .. ", Actual: " .. tostring(val:to_num()))
  end
  print("Completed test t1")
end

tests.t2 = function()
  local len = 66
  local in_table = {}
  local exp_table = {}
  for i = 1, len do
    in_table[i] = 0
    exp_table[i] = 1
  end
  local col = Q.mk_col(in_table, "B1")
  local n_col = Q.vnot(col)
  n_col:eval()
  local n_sum = Q.sum(n_col):eval()
  
  -- TODO: below assert fails, this is because of vec_add_B1 method, 
  -- it copies extra bits from last byte if len is not multiple of 8, discuss with Ramesh
  assert(n_sum:to_num() == len)

  local val, nn_val
  for i = 1, n_col:length() do
    val, nn_val = n_col:get_one(i-1)
    assert(val:to_num() == exp_table[i])
  end
  print("Completed test t2")
end

return tests
