-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local tests = {}
--=========================================
tests.t1 = function()
  for iter = 1, 100 do 
    local x = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 65537 } )
    assert(type(x) == "lVector")
    assert(x:qtype() == "F8")
    local y = Q.sum(x)
    assert(type(y) == "Reducer")
    local n, m = y:eval()
    assert(type(n) == "Scalar")
    assert(n:qtype() == "F8")
    assert(m:qtype() == "I8")
  end
  print("Test t1 succeeded")
end
--=========================================
tests.t2 = function()
  local n = 1048576+17
  local y = Q.seq({start = 1, by = 1, qtype = "I4", len = n })
  assert(type(y) == "lVector")
  local z = Q.sum(y):eval():to_num()
  assert( z == (n * (n+1) / 2 ) )
  print("Test t2 succeeded")
end
--=========================================
tests.t3 = function()
  local n = 1048576+17
  local y = Q.const({val = true, qtype = "B1", len = n })
  local z = Q.sum(y):eval():to_num()
  assert(z == n)
  print("Test t3 succeeded")
end
--=========================================
--[[
return tests
os.exit()
--]]
-- TODO tests.t1()
tests.t2()
-- TODO tests.t3()
