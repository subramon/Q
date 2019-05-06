local qc = require 'Q/UTILS/lua/q_core'

local use_terra = false
if arg[1] then
  if string.lower(arg[1]) == "true" then
    use_terra = true
  end
end

if use_terra then
  print("Using terra library")
  require 'terra'
end

local Q = require 'Q'
local col_1 = Q.const({ val = 1, qtype = "I1", len = 100000000} ):eval()
local start_timer = qc.RDTSC()
local res = Q.logit(col_1):eval()
local stop_timer = qc.RDTSC()
print("logit execution time:", stop_timer - start_timer)
