-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local test = {}

test.t1 = function()
  local x1 = Q.mk_col({0.0656218, -1.9030321, -0.5905962, 0.7218398, 0.7218398, 0.0656218, -1.2468141, 1.3780577, 0.0656218, 0.7218398}, "F4")
  local x2 = Q.mk_col({0.3162278, -1.5811388, -0.3162278, 1.5811388, 0.9486833, -0.9486833, -0.3162278, 0.9486833, 0.3162278, -0.9486833}, "F4")
  local x3 = Q.mk_col({-0.74819953, 1.03322792, -0.03562855, -1.46077051, 0.67694243, 1.38951342, -0.74819953, 1.03322792, -0.03562855, -1.10448502}, "F4")
  local X = {x1, x2, x3}
  local corrm  = Q.corr_mat(X)
  assert(type(corrm) == "table")
  assert(#corrm == 3)
  print("Completed corrm")
  local opt_args = { opfile = "" }
  for i=1,3 do
    assert(corrm[i]:length() == 3)
    --Q.print_csv(corrm[i], opt_args)
    --print("=====colbreak=======")
  end
  Q.print_csv(corrm, opt_args)
  print("SUCCESS")
end

return test
