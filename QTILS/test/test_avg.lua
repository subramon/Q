local tests = {}
local Q = require 'Q'

tests.t1 = function()
  local in_table = {}
  local len = 4
  for i = 1, len do
    in_table[i] = i
  end
  local a = Q.mk_col(in_table, "I4")
  local avg = Q.avg(a)
  local exp_val = ( ( len * ( len + 1 ) ) / 2 ) / len
  assert(avg:to_num() == exp_val)
  print("successfully executed t1")
end

tests.t2 = function()
  -- Test with more than chunk size elements
  local in_table = {}
  local len = 65536 + 577
  for i = 1, len do
    in_table[i] = i
  end
  local a = Q.mk_col(in_table, "I4")
  local avg = Q.avg(a)
  local exp_val = ( ( len * ( len + 1 ) ) / 2 ) / len
  assert(avg:to_num() == exp_val)
  print("successfully executed t2")
end

return tests
