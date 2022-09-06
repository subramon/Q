local ffi    = require 'ffi'
local cmem   = require 'libcmem'
local cutils = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr = require 'Q/UTILS/lua/get_ptr'

local tests = {}
tests.t1 = function()
  local x, y = lVector({ qtype = "F4", width = 4, chunk_size = 0 })
  assert(type(x) == "lVector")
  assert(type(y) == "nil") -- only one thing returned
  x = nil
  collectgarbage()
  print("Test t1 succeeded")
end
tests.t2 = function()
  local qtype = "I4"
  local chunk_size = 16
  local x = lVector({ qtype = qtype, chunk_size = chunk_size })
  assert(type(x) == "lVector")
  assert(x:num_elements() == 0)
  assert(x:is_eov() == false)
  local width = cutils.get_width(qtype)
  assert(x:width() == width)
  -- create a buffer for data to put into vector 
  local size = 1 * width
  local buf = cmem.new( {size = size, qtype = qtype, name = "inbuf"})
  -- put some stuff
  local iptr = assert(get_ptr(buf, qtype))
  for i = 1, chunk_size do 
    iptr[0] = i + 1 
    x:put1(buf, 1)
    assert(x:num_elements() == i)
  end
  print("Test t2 succeeded")
end
-- return tests
tests.t1()
tests.t2()

