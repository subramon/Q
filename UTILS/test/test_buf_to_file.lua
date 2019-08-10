-- FUNCTIONAL
local qc  = require 'Q/UTILS/lua/q_core'
local ffi = require 'ffi'
local cmem = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function()

-- START: Create and initialize some memory 
local nmemb = 65536
local size = ffi.sizeof("int32_t")
local addr = get_ptr(cmem.new(nmemb * size))
addr = ffi.cast("int32_t *", addr)
for i = 1, nmemb do
  addr[i-1] = i
end
--  addr = ffi.cast("char * ", addr)
addr = ffi.cast("const char * const ", addr)
-- STOP : Create and initialize some memory 

for i = 1, 128 do
  local len = 48
  local file_name = cmem.new(len)
  file_name:zero()
  file_name = ffi.cast("char *", get_ptr(file_name))
  local status = qc['rand_file_name'](file_name, len-1)
  assert(status == 0)
  print(i, addr, ffi.string(file_name))
  status = qc['buf_to_file'](addr, size, nmemb, file_name)
  print(status)
  assert(status == 0)
end
end
return tests
