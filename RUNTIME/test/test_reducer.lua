local Q = require 'Q'
local Scalar = require 'libsclr'
local m = 65536 - 1
local tests = {}
tests.t1 = function(n)
  if ( not n ) then n = m end 
  local random_vec = Q.rand({lb = 10, ub = 100, qtype = "I4", len = n})
  local x = Q.sum(random_vec)
  local n1, n2 = x:eval()
  print(n1, n2)
  print("Completed Test t1")
end
tests.t1()
return tests
