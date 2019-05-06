-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local tests = {}
tests.t1 = function()
  local n
  n = 67
  n = 32768
  n = 32768+10923
  print("n = ", n)
  local len = n * 3 
  local y = Q.period({start = 1, by = 2, period = 3, qtype = "I4", len = len })
  local actual = Q.sum(y):eval():to_num()
  local expected = (n * (1+3+5))
  assert (actual == expected )
  print("successfully executed t1")
end
return tests
