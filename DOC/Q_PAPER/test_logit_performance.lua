local Q		= require 'Q'
local qc	= require 'Q/UTILS/lua/q_core'

local tests = {}
local len = 100000000

tests.t1 = function()
  -- With Q.logit(), C and Lua combination
  local x = Q.seq({start = 0.1, by = 0.1, qtype = "F8", len = len}):eval()
  local start_time = qc.RDTSC()
  local y = Q.logit(x):eval()
  local stop_time = qc.RDTSC()
  local z, w = Q.sum(y):eval()
  print(z, w)
  print("logit (C  ) = ", stop_time-start_time)
end

tests.t2 = function()
  -- With Lua implementation
  local logit = require 'Q/DOC/CIDR2019/logit'
  local x = Q.seq({start = 0.1, by = 0.1, qtype = "F8", len = len}):eval()
  local start_time = qc.RDTSC()
  local y = logit(x)
  local stop_time = qc.RDTSC()
  local z, w = Q.sum(y):eval()
  print(z, w)
  print("logit (Lua) = ", stop_time-start_time)
end

return tests
