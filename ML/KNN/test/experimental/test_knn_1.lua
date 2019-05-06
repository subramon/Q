local Q = require 'Q'
local Scalar = require 'libsclr'
local knn = require 'Q/ML/KNN/lua/knn'

local tests = {}

-- testing knn.lua for desired results
tests.t1 = function()
  
  local T = {}
  local T_vec_1 = Q.mk_col({10, 20, 30, 40}, "I4")
  local T_vec_2 = Q.mk_col({20, 30, 40, 50}, "I4")
  local T_vec_3 = Q.mk_col({15, 12, 18, 22 }, "I4")
  T[#T+1] = T_vec_1
  T[#T+1] = T_vec_2
  T[#T+1] = T_vec_3

  local g = Q.mk_col({ 1, 0, 1, 0}, "F4")
  -- For qtype I4 knn does not return 1 as expected goal value,
  -- it return something like 1.401298e-45 for respective goal value 1
  -- local g = Q.mk_col({ 1, 0, 1, 0}, "I4")

  local x = { Scalar.new(5, "I4"), Scalar.new(15, "I4"), Scalar.new(10, "I4")}
  local k = 2

  local res = knn(T, g, x, k)
  
  local val, goal = res:eval()
  print("========================")
  for i, v in ipairs(val) do
    print(val[i], goal[i])
  end
  print("========================")
  print("completed t1 successfully")
end

return tests
