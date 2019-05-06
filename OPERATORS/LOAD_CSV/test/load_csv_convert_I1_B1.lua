local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local input_col
local expected_col
local converted_col

local test_convert = {}

test_convert.t1 = function()
  
  local M_I1 =  { { name = "colI1", qtype = "I1", has_nulls = false, is_load = true }}
  input_col = Q.load_csv( "valid_I1.csv", M_I1 )
  -- print(type(input_col[1]))
  print("-----------------------------------------------")
  print("After LOAD_CSV\nnum_elements:",input_col[1]:num_elements()," qtype:", input_col[1]:qtype())
  print("Printing values after load_csv(I1)")
  for i = 1, input_col[1]:num_elements() do
    local val = c_to_txt(input_col[1],i)
    print(val)
  end
  print("-----------------------------------------------")

  local expected_res = { 1, 0, 1 }
  converted_col = Q.convert(input_col[1], "B1")

  converted_col:eval()
  print("-----------------------------------------------")
  print("After convert(I1 to B1)")
  print("num_elements:",converted_col:num_elements()," qtype:", converted_col:qtype())
  print("Printing values after CONVERT I1 to B1")
  -- Q.print_csv(converted_col, { opfile =  "" })
  -- Compare converted column with expected column
  for i, v in pairs(expected_res) do
    local val = c_to_txt(converted_col, i)
    if not val then val = 0 end
    print(val)
    assert(val == v, "Value mismatch")
  end

  local M_B1 =  { { name = "colB1", qtype = "B1", has_nulls = false, is_load = true }}
  input_col = Q.load_csv( "valid_B1.csv", M_B1 )
  assert(converted_col:num_elements() == input_col[1]:num_elements(),"columns not of same length")
  print("-----------------------------------------------")
  print("Printing values of CONVERT(I1 to B1) and load_csv(B1)")
  print("-----------------------------------------------")
  for i=1, input_col[1]:num_elements() do
    local convert_val = c_to_txt(converted_col, i)
    local load_val = c_to_txt(input_col[1], i)
    if not convert_val then convert_val = 0 end
    if not load_val then load_val = 0 end
    print(convert_val, load_val)
    assert(convert_val == load_val, "Value mismatch")
  end
  print("-----------------------------------------------")
end

return test_convert
