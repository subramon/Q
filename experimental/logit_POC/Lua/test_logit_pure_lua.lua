local qconsts	= require 'Q/UTILS/lua/q_consts'
local qc = require 'Q/UTILS/lua/q_core'

local function logit(in_buf, num_elements, out_buf)
  for i = 1, num_elements do -- core operation is as follows
    out_buf[i] = 1.0 / (1.0 + math.exp(-1 * in_buf[i]))
  end
  return out_buf
end

local num_elements = 10000000
local in_buf = {}
local out_buf = {}

-- Initialize input arrays
for i = 1, num_elements do
  in_buf[i] = 2
end


local start_time = qc.RDTSC()
for i = 1, 100 do
  local res = logit(in_buf, num_elements, out_buf )
end
local stop_time = qc.RDTSC()
local time = stop_time - start_time

print("Time required for pure lua execution is = " .. tostring(time))

-- Validate result
for i = 1, num_elements do
  -- print(res[i])
  --assert(res[i] == i*2)
end
