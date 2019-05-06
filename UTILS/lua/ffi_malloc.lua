local ffi = require 'ffi'
local log = require "log"
ffi.cdef([[
void * malloc(size_t size);
void free(void *ptr);
]])

return function(n)
   log.warn("Will be deprecated soon, use qcore.malloc")
   assert(n > 0, "Cannot malloc 0 or less bytes")
  local c_mem = assert(ffi.gc(ffi.C.malloc(n), ffi.C.free))
  return c_mem
end
