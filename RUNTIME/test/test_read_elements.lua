local lVector = require 'Q/RUNTIME/lua/lVector'
local cmem = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'

local tests = {}

tests.t1 = function()
  print("Creating nascent vector")
  local x = lVector( { qtype = "I4", gen = true, has_nulls = false, is_memo = true })
  x:set_name("x_vec")
  local y = lVector( { qtype = "I4", gen = true, has_nulls = false, is_memo = true })
  y:set_name("y_vec")
  local num_elements = qconsts.chunk_size + 1000
  local field_size = 4
  local base_data = cmem.new(num_elements * field_size)
  base_data:zero()
  local buf = get_ptr(base_data, "I4")
  for i = 1, num_elements do
    buf[i-1] = i
  end
  x:put_chunk(base_data, nil, num_elements)  -- Now 'x' vector has two chunks
  y:put_chunk(base_data, nil, num_elements)  -- Now 'y' vector has two chunks
  assert(x:check())
  --assert(y:check())

  local len, data, nn_data
  -- ## current state of vector 'x' is "is_nascent = true, is_eov = false"
  -- ## current state of vector 'y' is "is_nascent = true, is_eov = false"

  -- get current chunk of 'x', should be served from in-memory
  print("Should be served from in-memory")
  len, data, nn_data = x:chunk(1)
  assert(x:check())
  assert(y:check())

  -- get previous chunk of 'x', should be served from file
  print("Should be served from file")
  len, data, nn_data = x:chunk(0)
  assert(x:check())
  assert(y:check())

  -- call eov()
  x:eov()
  y:eov()
  assert(x:check())
  assert(y:check())

  -- ## current state of vector 'x' is "is_nascent = true, is_eov = true"
  -- ## current state of vector 'y' is "is_nascent = true, is_eov = true"

  -- get current chunk of 'x', should be served from in-memory
  print("Should be served from in-memory")
  len, data, nn_data = x:chunk(1)
  assert(x:check())
  assert(y:check())

  -- get previous chunk of 'x', should be served using mmap pointer
  print("should be served using mmap pointer")
  len, data, nn_data = x:chunk(0)
  assert(x:check())
  assert(y:check())

  -- get current chunk of 'x' again, should be served from in-memory
  print("should be served from in_memory")
  len, data, nn_data = x:chunk(1)
  assert(x:check())
  assert(y:check())

  -- Call start_write on 'y' so that vector's state will change
  y:start_write()
  assert(x:check())
  assert(y:check())

  y:end_write()
  assert(x:check())
  assert(y:check())

  -- ## current state of vector 'y' is "is_nascent = false, is_eov = true"

  -- get current chunk of 'y', should be served using mmap pointer
  print("should be served using mmap pointer")
  len, data, nn_data = y:chunk(1)
  assert(x:check())
  assert(y:check())

  -- get previous chunk of 'y', should be seved using mmap pointer
  print("should be served using mmap pointer")
  len, data, nn_data = y:chunk(0)
  assert(x:check())
  assert(y:check())

  assert(x:check())
  assert(x:length() == num_elements)
  -- validate values
  --[[
  local val, nn_val
  for i = 1, x:length() do
    val, nn_val = x:get_one(i-1)
    assert(val:to_num() == i)
  end
  ]]
  print("Successfully completed test t1")
end

tests.t1()

return tests
