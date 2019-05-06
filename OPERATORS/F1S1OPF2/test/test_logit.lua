-- FUNCTIONAL STRESS
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qc	= require 'Q/UTILS/lua/q_core'
local Scalar = require 'libsclr'

local tests = {}
tests.t1 = function() 
  local x = Q.mk_col( {0.1,0.2,0.3,0.4,0.5,0.6,0.7,0.8}, "F8")
  local y = Q.logit(x):eval()
--[[
  local opt_args = { opfile = "" }
  print("=START x =========")
  Q.print_csv(x, opt_args)
  print("=STOP  x==========")
  print("=START y =========")
  Q.print_csv(y, opt_args)
  print("=STOP  y==========")
  local z = Q.vvdiv(Q.exp(x), Q.vsadd(Q.exp(x), 1)):eval()
  print("=START z =========")
  Q.print_csv(z, opt_args)
  print("=STOP  z==========")
  assert(Q.vvseq(y, z, 0.01))
  print("====++++++========")
  print(Q.logit(x))
  print(Q.vvdiv(Q.exp(x), Q.vsadd(Q.exp(x), 1)))
--]]
  assert(Q.vvseq(Q.logit(x), Q.vvdiv(Q.exp(x), Q.vsadd(Q.exp(x), Scalar.new(1, "F8"))), 0.01))
  print("Test t1 succeeded")
end
tests.t2 = function() 
  local len = 1 * 1000000
  local x = Q.rand({ lb = 0.01, ub = 0.09, qtype = 'F4', len = len }):eval()
  local start = qc.RDTSC()
  local y = Q.logit(x):eval()
  local stop = qc.RDTSC()
  print(stop - start)
  print("Test t2 succeeded")
end
return tests
