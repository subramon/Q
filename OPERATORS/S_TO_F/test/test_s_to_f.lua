-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local tests = {}
tests.t1 = function()
  local z
  z = Q.const( { val = 5, qtype = "I4", len = 10 }):eval()
  Q.print_csv(z)
  z = Q.rand( { lb = 100, ub = 200, seed = 1234, qtype = "I4", len = 10 }):eval()
  print("==============================")
  Q.print_csv(z)
  z = Q.seq( {start = -1, by = 5, qtype = "I4", len = 10} ):eval()
  print("==============================")
  Q.print_csv(z)
  --=======================================
end
return tests
