local ffi = require 'ffi'
local plfile = require 'pl.file'
local qc = require 'Q/UTILS/lua/q_core'

local header_file = "logit_I8.h"
ffi.cdef([[
  void * malloc(size_t size);
  void free(void *ptr);
  ]])
ffi.cdef(plfile.read(header_file))
local qc = ffi.load('liblogit_I8.so')

local num_elements = 10000000

local function logit()
  local in_buf, nn_in_buf, out_buf, nn_out_buf
  local num_width = 8
  local func_name = "logit_I8"
  
  -- allocate memory
  in_buf = ffi.gc(ffi.C.malloc(num_width * num_elements), ffi.C.free)
  out_buf = ffi.gc(ffi.C.malloc(num_width * num_elements), ffi.C.free)

  -- cast appropriately
  in_buf = ffi.cast("int64_t *", in_buf)
  out_buf = ffi.cast("double *", out_buf)
  
  -- Initialize input arrays
  for i = 1, num_elements do
    in_buf[i-1] = 2
  end
  
  local start_time = qc.RDTSC()
  for i = 1, 100 do
    qc[func_name](in_buf, nil, num_elements, nil, out_buf, nil)
  end
  local stop_time = qc.RDTSC()
  local time = stop_time - start_time

  print("Time required for C execution is = " .. tostring(time))

  -- Validate result
  out_buf = ffi.cast("double *", out_buf)
  for i = 1, num_elements do
    --print(out_buf[i-1])
    --assert(out_buf[i-1] == i*2)
  end

  print("DONE")
  os.exit()
end

logit()
