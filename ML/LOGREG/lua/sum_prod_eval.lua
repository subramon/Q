local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'

function sum_prod_eval(X, w)
  local A = {}

  for i = 1, #X do
    A[i] = {}
    local temp = Q.vvmul(X[i], w)
    for j = i, #X do
      A[i][j] = Q.sum(Q.vvmul(X[j], temp)):eval()
    end
  end

  return A
end
return sum_prod_eval
