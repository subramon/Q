
local qc = require 'Q/UTILS/lua/q_core'
local cmem = require 'libcmem'
local ffi = require 'Q/UTILS/lua/q_ffi'

local tests = {}

tests.t1 = function()
  local infile = "test_file"

  -- create test file
  local f = io.open(infile, "w")
  f:write("abcde")
  f:close()

  --local mmaped_file = cmem.new(ffi.sizeof("char *"), "F4", "file")
  local mmaped_file = ffi.gc(ffi.C.malloc(ffi.sizeof("char *")), ffi.C.free)
  mmaped_file = ffi.cast("char **", mmaped_file)
  --local file_size = cmem.new(ffi.sizeof("size_t"), "F4", "size")
  local file_size = ffi.gc(ffi.C.malloc(ffi.sizeof("size_t")), ffi.C.free)
  file_size = ffi.cast("size_t *", file_size)
  local status = qc.rs_mmap(infile, mmaped_file, file_size, false)
  assert(status == 0)
  print("file size ", file_size[0]);

  local X = ffi.cast("char *", mmaped_file[0])
  status = qc.rs_munmap(mmaped_file[0], file_size[0])
  assert(status==0)

  qc.delete_file(infile)

  print("Successfully completed test")
end

return tests
