local Q = require 'Q'

local okfldtypes = {}
okfldtypes["F4"] = true
okfldtypes["F8"] = true

local function predict1(
  betas,
  x, -- point whose classification we desire
  is_fast
  )
  -- CHECK params
  if ( not is_fast ) then 
    assert(type(betas) == "lVector")
    assert(type(x)     == "lVector")
    assert(okfldtypes[betas:fldtype()])
    assert(okfldtypes[x:fldtype()])
    assert(betas:length() == x:length())
  end
  --=======================================
  local tmp1 = Q.vvmul(x, betas):eval()
  local jnk, _ = Q.max(tmp1):eval()
  local x_beta, n = Q.sum(tmp1):eval()
  local exp_neg_x_beta = math.exp(-1 * x_beta:to_num())
  local prob = (1.0 / ( 1 + exp_neg_x_beta))
  return prob
end
return predict1


