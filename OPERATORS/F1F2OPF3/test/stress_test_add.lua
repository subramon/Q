-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'

local tests = {}

local function foo (x)
  local y = Q.vvadd(x, x)
  return y
end

tests.t1 = function()
  local z = Q.const({val = 10, len = 10, qtype = "F8"})
  for i = 1, 100000000 do
    local z = foo(z) -- THIS WORKS 
  --[[
    z = foo(z) -- THIS BLOWS UP
  --]]
    if ( ( i % 1000000) == 0 ) then print("Iteration ", i) end
  end
  print("Test OPERATORS/F1F2OPF3/test/stress_test_add.lua succeeded")
end
return tests
