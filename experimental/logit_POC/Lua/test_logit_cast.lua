local qconsts	= require 'Q/UTILS/lua/q_consts'
local ffi	= require 'Q/UTILS/lua/q_ffi'
local qc	= require 'Q/UTILS/lua/q_core'

local function logit(in_buf, in_qtype, num_elements, out_buf, out_qtype)
  in_buf = ffi.cast(in_qtype, in_buf)
  for i = 0, num_elements do -- core operation is as follows
    out_buf[i] = 1.0 / (1.0 + math.exp(-1 * tonumber(in_buf[i])))
  end
  return out_buf
end

local num_elements = 10000000
local in_qtype = "int64_t *"
local out_qtype = "double *"
local in_buf, out_buf
local num_width = 8

-- allocate memory
in_buf = ffi.gc(ffi.C.malloc(num_width * num_elements), ffi.C.free)
out_buf = ffi.gc(ffi.C.malloc(num_width * num_elements), ffi.C.free)

-- cast appropriately
in_buf = ffi.cast(in_qtype, in_buf)
out_buf = ffi.cast(out_qtype, out_buf)

-- Initialize input arrays
for i = 1, num_elements do
  in_buf[i-1] = 2
end


local start_time = qc.RDTSC()
for i = 1, 100 do
  local res = logit(in_buf, in_qtype, num_elements, out_buf, out_qtype )
end
local stop_time = qc.RDTSC()
local time = stop_time - start_time

print("Time required for lua execution is = " .. tostring(time))

-- Validate result
res = ffi.cast("double *", res)
for i = 1, num_elements do
  -- print(res[i-1])
  --assert(res[i-1] == i*2)
end
