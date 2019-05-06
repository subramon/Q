local ffi = require 'ffi'
local plfile = require 'pl.file'
local timer = require 'posix.time'

local num_elements = 100000000

local header_file = "vvadd_I4_I4_I4.h"
ffi.cdef([[
  void * malloc(size_t size);
  void free(void *ptr);
  ]])
ffi.cdef(plfile.read(header_file))
local qc = ffi.load('libvvadd_I4_I4_I4.so')

local function vvadd()
  local in_buf1, in_buf2, out_buf
  local num_width = 4
  local func_name = "vvadd_I4_I4_I4"
  
  -- allocate memory
  in_buf1 = ffi.gc(ffi.C.malloc(num_width * num_elements), ffi.C.free)
  in_buf2 = ffi.gc(ffi.C.malloc(num_width * num_elements), ffi.C.free)
  out_buf = ffi.gc(ffi.C.malloc(num_width * num_elements), ffi.C.free)

  -- cast appropriately
  in_buf1 = ffi.cast("int32_t *", in_buf1)
  in_buf2 = ffi.cast("int32_t *", in_buf2)
  out_buf = ffi.cast("int32_t *", out_buf)
  -- Initialize input arrays
  for i = 1, num_elements do
    in_buf1[i-1] = i
    in_buf2[i-1] = i
  end
  
  local start_time = timer.clock_gettime(0)
  qc[func_name](in_buf1, in_buf2, num_elements, out_buf)
  local stop_time = timer.clock_gettime(0)
  local time =  (stop_time.tv_sec*10^6 +stop_time.tv_nsec/10^3 - (start_time.tv_sec*10^6 +start_time.tv_nsec/10^3))/10^6

  print("Time required for C execution is = " .. tostring(time))

  -- Validate result
  out_buf = ffi.cast("int32_t *", out_buf)
  for i = 1, num_elements do
    assert(out_buf[i-1] == i*2)
  end

  print("DONE")
end

vvadd()
