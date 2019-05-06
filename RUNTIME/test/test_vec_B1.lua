local cmem = require 'libcmem'
local Scalar = require 'libsclr'
local lVector = require 'Q/RUNTIME/lua/lVector'
local ffi = require 'Q/UTILS/lua/q_ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'


local tests = {}

tests.t1 = function()
  local vec_len = 65536
  local n1 = vec_len / 8
  local buf = cmem.new(n1, "I1", "buffer")
  local I1ptr = assert(get_ptr(buf, "uint8_t"))

  -- for the first n1 bytes, we set it to 01010101
  -- this means, that the first n1*8 values are alternating as 0 and 1
  for i = 1, n1 do
    I1ptr[i-1] = 85
  end

  -- Create B1 Vector
  local b1_vec = lVector({qtype = "B1", gen = true, has_nulls = false})
  b1_vec:put_chunk(buf, nil, vec_len)
  -- now we set the buffer to all 1's
  for i = 1, n1 do
    I1ptr[i-1] = 255
  end
  -- however, we put only 4 bits
  b1_vec:put_chunk(buf, nil, 4)
  b1_vec:eov()

  for i = 1, vec_len do
    local exp_val
    if i % 2 == 1 then
      exp_val = Scalar.new("true", "B1")
    else
      exp_val = Scalar.new("false", "B1")
    end

    local s1 = b1_vec:get_one(i-1)
    assert(type(s1) == "Scalar")
    assert(s1 == exp_val)
  end

  for i = 1, 4 do
    local exp_val = Scalar.new(1, "B1")
    local s1 = b1_vec:get_one(vec_len+i-1)
    assert(type(s1) == "Scalar")
    assert(s1 == exp_val)
  end
  print("COMPLETED")
end

return tests
