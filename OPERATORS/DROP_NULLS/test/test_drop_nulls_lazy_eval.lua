-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local C_to_txt = require "Q/UTILS/lua/C_to_txt"
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi     = require 'Q/UTILS/lua/q_ffi'
local Scalar = require 'libsclr' ; 
local cmem    = require 'libcmem';
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local tests = {}

tests.t1 = function()
  local x_length = 10
  local x_qtype = "I4"
  local M =  { qtype = x_qtype, gen = true,  has_nulls = true,  is_memo = true, num_elements = x_length }
  -- creating a vector
  local x = lVector(M)
  
  -- providing value for vector
  local x_width = qconsts.qtypes[x_qtype].width
  local base_data = cmem.new(x_length * x_width)
  local iptr = ffi.cast(qconsts.qtypes[x_qtype].ctype .. " *", get_ptr(base_data))
  for itr = 1, x_length do
    iptr[itr - 1] = itr * 10
  end
  -- creating vector with nulls to serve as an input for drop_nulls
  -- treating nn vector as I1
  local field_size = 8
  local qtype = "I1"
  local num_elements = math.ceil(x_length / 8)

  local nn_data = cmem.new(num_elements * field_size)
  local nn_iptr = ffi.cast(qconsts.qtypes[qtype].ctype .. " *", get_ptr(nn_data))
  for itr = 1, num_elements do
    nn_iptr[itr - 1] = 85
  end 
  
  -- writing values to vector
  x:put_chunk(base_data, nn_data, x_length)
  -- Q.print_csv(x)
  local sval = Scalar.new("1000", "I4")
  local z = Q.drop_nulls(x, sval)

  Q.print_csv(z)
  
  assert(Q.sum(z):eval():to_num() == 5250)
  print("Test t1 succeeded")
end

return tests
