local cmem    = require 'libcmem'
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
require 'Q/UTILS/lua/strict'


local tests = {}

--====== Testing nascent vector write operation where len > chunk_size
tests.t1 = function()
  print("Creating nascent vector")
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false, is_memo = true })
  local num_elements = qconsts.chunk_size + 1000
  local field_size = 4
  local base_data = cmem.new(num_elements * field_size)
  base_data:zero()
  local buf = get_ptr(base_data, "I4")
  for i = 1, num_elements do
    buf[i-1] = i
  end
  x:put_chunk(base_data, nil, num_elements)
  assert(x:check())
  x:eov()
  assert(x:check())
  assert(x:length() == num_elements) 
  -- validate values
  local val, nn_val
  for i = 1, x:length() do
    val, nn_val = x:get_one(i-1)
    assert(val:to_num() == i)
  end
  print("Successfully completed test t1")
end

return tests
