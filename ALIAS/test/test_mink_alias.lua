local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'

local tests = {}

-- Q.mink should call Q.mink_vector
tests.t1 = function()
  local col = Q.mk_col({1, 5, 4, 2, 3, 7, 9}, "I4")
  local res = Q.mink(col, 3)
  local exp_col = Q.mk_col({1, 2, 3}, "I8")
  local sum = Q.sum(Q.vveq(res, exp_col)):eval()
  assert(sum:to_num() == exp_col:length())
  print("successfully completed t1")
end

-- Q.mink should call Q.mink_reducer
tests.t2 = function()
  local val = Q.mk_col({1, 5, 4, 2, 3, 7, 9}, "F4")
  local drag = Q.mk_col({0, 1, 1, 1, 0, 0, 0}, "I4")
  local res = Q.mink(val, drag, 3)
  local val_k, drag_k = res:eval()
  print("========================")
  for i, v in ipairs(val_k) do
    print(val_k[i], drag_k[i])
  end
  print("successfully completed t2")
end

return tests
