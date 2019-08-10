-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local plpath = require "pl.path"
local ffi = require 'ffi'
local Q = require 'Q'
local cmem = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local tests = {}
-- Helper function to calculate file size.
local function filesize (fd)
   local current = fd:seek()
   local size = fd:seek("end")
   fd:seek("set", current)
   return size
end

local function get_file_bytes(filename)
   local fd, err = io.open(filename, "rb")
   if err then error(err) end

   -- Get size of file and allocate a buffer for the whole file.
   local size = filesize(fd)
   local buffer = ffi.cast("uint8_t*", get_ptr(cmem.new(ffi.sizeof("uint8_t") * size)))

   -- Read whole file and store it as a C buffer.
   ffi.copy(buffer, fd:read(size), size)
   fd:close()
   return buffer, size
end


tests.t1 = function() 
  -- "vveq results should be multiples of 8 bytes"
  local c1 = Q.mk_col({80, 70, 60, 50, 40, 30, 20, 10}, "I4")
  local c2 = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, "I4")
  -- "when vectors are equal"i
  local w = Q.vveq(c1,c1)
  w:eval()
  local f_name = w:meta().base.file_name
  assert(plpath.getsize(f_name) == 8)
  local bytes, size = get_file_bytes(f_name)
  assert(size == 8)
  assert(bytes[0] == 255)
  for i=2,size -1 do
     assert(bytes[i] == 0)
  end
  -- " vveq results should be multiples of 8 bytes even when vectors are not equal"
  local w = Q.vveq(c1,c2)
  w:eval()
  local f_name = w:meta().base.file_name
  assert(plpath.getsize(f_name) == 8)
  local bytes, size = get_file_bytes(f_name)
  assert(size == 8)
  for i=1,size -1 do
     assert(bytes[i] == 0)
  end
  print("Test t1 succeeded")
end
return tests
