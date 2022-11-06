-- FUNCTIONAL
-- TODO P3 Understand what this test is trying to do 
require 'Q/UTILS/lua/strict'
local cutils = require 'libcutils'
local Q = require 'Q'

local tests = {}
local function foo (x)
  local xsum = Q.sum(x):eval()
  local y = Q.const({val = 100, len = 10, qtype = "F8"})
  return y
end

tests.t1 = function()
  local start_time = cutils.rdtsc()
  local z = Q.const({val = 10, len = 10, qtype = "F8"})
  for i = 1, 1000000 do
  --[[
    local z = foo(z) === THIS WORKS
    z = foo(z) === THIS BLOWS UP
  --]]
    z = foo(z)
    if ( ( i % 1000) == 0 ) then print("Iteration ", i) end
  end
  local stop_time = cutils.rdtsc()
end
tests.t1()

-- return tests
