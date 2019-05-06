-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local tests = {}
--=========================================
tests.t1 = function()
  for iter = 1, 100 do 
    Q.sum(Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 65537 } )):eval()
  end
  print("Test t1 succeeded")
--=========================================
end
tests.t2 = function()
  local n = 1048576+17
  local y = Q.seq({start = 1, by = 1, qtype = "I4", len = n })
  local z = Q.sum(y):eval():to_num()
  assert( z == (n * (n+1) / 2 ) )
  print("Test t2 succeeded")
end
--=========================================
return tests
