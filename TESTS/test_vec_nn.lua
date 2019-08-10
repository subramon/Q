local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
local cmem = require 'libcmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local Q	= require 'Q'


local tests = {}

tests.t1 = function()
  local x = lVector({qtype = "I4", gen = true, has_nulls = true})

  local x_length = 10
  local nn_buf_sz = qconsts.chunk_size  -- over allocating


  local x_buf = cmem.new(qconsts.qtypes.I4.width * x_length)
  local x_buf_copy = ffi.cast(qconsts.qtypes.I4.ctype .. " *", get_ptr(x_buf))

  local nn_buf = cmem.new(nn_buf_sz)
  local nn_buf_copy = ffi.cast("int8_t *", get_ptr(nn_buf))

  for i = 1, x_length do
    x_buf_copy[i-1] = i
  end

  for i = 1, nn_buf_sz do
    -- 85 to binary = 01010101
    nn_buf_copy[i-1] = 85
  end

  x:put_chunk(x_buf, nn_buf, x_length)
  x:eov()

  --Q.print_csv(x)
  for i = 1, x_length do
    local val, nn_val = c_to_txt(x, i)
    print(val, nn_val)
  end
end

return tests
