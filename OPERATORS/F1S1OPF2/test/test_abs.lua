local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local Scalar = require 'libsclr'

local tests = {}
tests.t1 = function()
  local c1 = Q.rand({lb = -10, ub = 10, qtype = "I4", len = 10})
  local opt_args = { opfile = "" }
  -- c1:eval(); Q.print_csv(c1, opt_args)
  local c1 = Q.abs(c1)
  -- c1:eval() Q.print_csv(c1, opt_args)
  
  local num_lt_0 = Q.sum(Q.vslt(c1, Scalar.new(0, "I4"))):eval():to_num()
  assert(num_lt_0 == 0, "FAILURE")
end
return tests
