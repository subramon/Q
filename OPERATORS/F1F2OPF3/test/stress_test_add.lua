-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local qc = require 'Q/UTILS/lua/q_core'
local utils = require 'Q/UTILS/lua/utils'

local tests = {}

local function foo (x)
  local y = Q.vvadd(x, x)
  return y
end

tests.t1 = function()
  local start_time = qc.RDTSC()
  local z = Q.const({val = 10, len = 10, qtype = "F8"})
  for i = 1, 1000000 do
  --[[
    local z = foo(z) === THIS WORKS 
  --]]
    z = foo(z) -- THIS BLOWS UP
    if ( ( i % 1000) == 0 ) then print("Iteration ", i) end
  end
  local stop_time = qc.RDTSC()
  print("stress_test_add time(seconds): ", utils["RDTSC"](stop_time-start_time))
  print("Test OPERATORS/F1F2OPF3/test/stress_test_add.lua succeeded")
end
return tests
