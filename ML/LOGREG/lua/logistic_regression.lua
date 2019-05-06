local Q = require 'Q'

local T = {} -- table of functions to return 

local function beta_step(X, y, beta)
  local Xbeta = Q.mv_mul(X, beta):eval()

  local p     = Q.logit(Xbeta):eval()
  local w     = Q.logit2(Xbeta):eval()
  local ysubp = Q.vvsub(y, p):eval()
  local A = {} -- initially a table of Lua tables, later a table of lVectors
  local b = {} -- initially a Lua table, later a Q vector

  for i, X_i in ipairs(X) do
    b[i] = Q.sum(Q.vvmul(X_i, ysubp)):eval()
    A[i] = {}
    for j, X_j in ipairs(X) do
      A[i][j] = Q.sum( Q.vvmul(X_i, Q.vvmul(w, X_j))):eval()
    end
  end
  -- convert from Lua table to Q vector
  b = Q.mk_col(b, "F8")
  for i = 1, #A do
    A[i] = Q.mk_col(A[i], "F8")
  end

  local beta_new_sub_beta = Q.posdef_linear_solver(A, b)
  local beta_new = Q.vvadd(beta_new_sub_beta, beta)
  return beta_new

end
T.beta_step = beta_step


local function lr_setup(
  X, -- table of M columns of length N
  y  -- vector of length n containing classification label
)
  -- add an additional column to X of 1's. 
  -- Math justification in documentation
  local xtype = X[1]:fldtype()
  local n     = y:length()
  X[#X + 1] = Q.const({ val = 1, len = n, qtype = xtype }):eval()
  local M = #X
  --- initialize beta to 0 
  beta = Q.const({ val = 0, len = M, qtype = xtype })
  return beta
end
T.lr_setup  = lr_setup
-- TODO Do following for things that need to be exported
-- require('Q/q_export').export('make_logistic_regression_trainer', make_multinomial_trainer)

return T
