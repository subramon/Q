-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local tests = {}
--========================================
tests.t1 = function()
  local len = 1048576 * 4  + 19481;
  local p = 0.25;
  local actual = Q.sum(Q.rand( { probability = p, qtype = "B1", len = len })):eval():to_num()
  local expected = len * p
  print("len,p,actual,expected", len, p, actual, expected)
  assert( ( ( actual >= expected * 0.90 ) and
     ( actual <= expected * 1.10 ) ) )
  print("Test t1 succeeded")
end
--=======================================
return tests
