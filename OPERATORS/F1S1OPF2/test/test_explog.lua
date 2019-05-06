-- FUNCTIONAL STRESS
local Q = require 'Q'
local Scalar = require 'libsclr'
require 'Q/UTILS/lua/strict'
require('Q/UTILS/lua/cleanup')()

local tests = {}
tests.t1 = function()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
  local z = Q.vsadd(c1, Scalar.new(10, "I4") )
  local opt_args = { opfile = "" }
  -- z:eval(); Q.print_csv(z, opt_args)
  --===========================
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "F8")
  local z = Q.exp(c1)
  local opt_args = { opfile = "" }
  -- z:eval(); Q.print_csv(z, opt_args)
  --===========================
  local c1 = Q.mk_col( {0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8}, "F8")
  local z = Q.logit(c1)
  local opt_args = { opfile = "" }
  -- z:eval(); Q.print_csv(z, opt_args)
  --===========================
  local c1 = Q.mk_col( {0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8}, "F8")
  local z = Q.logit2(c1)
  local opt_args = { opfile = "" }
  -- z:eval() Q.print_csv(z, opt_args)
  
  for i = 1, 1000 do
    local z = Q.sum(Q.logit2(Q.logit(Q.log(Q.exp(Q.rand({ lb = 10, ub = 20, seed = 1234, qtype = "F4", len = 65537 } ))))))
    z:eval()
  end
end
return tests
