--[[ Guideline for adding new testcases in this file
File : map_vector.lua
In this file, all the testcases are written in the format
name = name of testcase
field_type = qtype of Vector 
filename = binary file of Vector
chunk_size = number of elements in a chunk
write_vector - true, if write mode , else false in read mode
input_values = data to be written to binary file
input_argument = argument to constructor of Vector. If present, will override the above arugments.

They are added as a row in the below LUA table.
category1 - successful testcase except B1 data types. Has both write and read mode cases
category2 - successful testcases on B1 data types. Has both write and read mode cases
category3 - error code testcases
For all the error codes , refer to UTILS/lua/error_codes.lua
In case, you want to add a test case with a new error code, add the error code in the UTILS/lua/error_codes.lua file.
--]]

local I1_data = { -128, 0, 127, 11, 5, 6, 7, 8 }
local I2_data = { -32768, 0, 32767, 11, 5, 6, 7, 8 }
local I4_data = { -2147483648, 0, 2147483647, 11, 5, 6, 7, 8 }
local I8_data = { 1,2,3,4,5,6,7,8 }
local F4_data = { -90000000.00, 0, 900000000.00, 11, 5, 6, 7, 8 }
local F8_data = { -90000000.00, 0, 900000000.00, 11, 5, 6, 7, 8 }
local SC_data = {  "Stestt", "testt", "Fohff","ddddsw", "dbjcf"}
local B1_data = { 1,0,0,0,0,1,1,1 }
local B1_odd_data = { 1,0,0,0,0,1,1,1,0 }

return {
  
  -- checks the name of the binary file created by calling eov function in vector class
  -- in this testcase, input values are written to binary file I1.bin.
  { name = "valid I1", field_type = 'I1', filename="I1.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = I1_data
  },
    -- write vector field not present
  { name = "nil write vector", field_type = 'I1', filename="I1.bin", chunk_size = 8, category = "category1",
    input_values = I1_data 
  },
    -- chunk size field not present
  { name = "nil chunk size", field_type = 'I1', filename="I1.bin", write_vector = true, category = "category1",
    input_values = I1_data 
  },
  --to make sure I1.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from I1.bin, and compare the values in binary file to values got by reading vector
  { name = "valid I1 read", field_type = 'I1', filename="I1.bin", chunk_size = 8, write_vector = false, category = "category1", input_values = I1_data
  },
  -- in this testcase, input values are written to binary file I2.bin.
  { name = "valid I2", field_type = 'I2', filename="I2.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = I2_data 
  },
  --to make sure I2.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from I2.bin, and compare the values in binary file to values got by reading vector
  { name = "valid I2 read", field_type = 'I2', filename="I2.bin", chunk_size = 8, write_vector = false, category = "category1",
    input_values = I2_data 
  },
  -- in this testcase, input values are written to binary file I4.bin.
  { name = "valid I4", field_type = 'I4', filename="I4.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = I4_data 
  },
  --to make sure I4.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from I4.bin, and compare the values in binary file to values got by reading vector
  { name = "valid I4 read", field_type = 'I4', filename="I4.bin", chunk_size = 8, write_vector = false, category = "category1",
    input_values = I4_data
  },
  -- in this testcase, input values are written to binary file F4.bin.
  { name = "valid F4", field_type = 'F4', filename="F4.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = F4_data
  },
  --to make sure F4.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from F4.bin, and compare the values in binary file to values got by reading vector
  { name = "valid F4 read", field_type = 'F4', filename="F4.bin", chunk_size = 8, write_vector = false, category = "category1",
    input_values = F4_data 
  },
  -- in this testcase, input values are written to binary file F8.bin.
  { name = "valid F8", field_type = 'F8', filename="F8.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = F8_data
  },
  --to make sure F8.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from F4.bin, and compare the values in binary file to values got by reading vector
  { name = "valid F8 read", field_type = 'F8', filename="F8.bin", chunk_size = 8, write_vector = false, category = "category1",
    input_values = F8_data 
  },
  -- in this testcase, input values are written to binary file SC.bin.
  { name = "valid SC", field_type = 'SC', filename="SC.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = SC_data 
  },
  --to make sure SC.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from SC.bin, and compare the values in binary file to values got by reading vector
  { name = "valid SC read", field_type = 'SC', filename="SC.bin", chunk_size = 8, write_vector = false, category = "category1",
    input_values = SC_data
  },
  -- in this testcase, input values are written to binary file SC.bin.
  -- field size of 10 is given
  { name = "valid SC", field_type = 'SC', filename="SC.bin", chunk_size = 8, write_vector = true, category = "category1", field_size = 10,
    input_values = SC_data 
  },
  --to make sure SC.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from SC.bin, and compare the values in binary file to values got by reading vector
  { name = "valid SC read", field_type = 'SC', filename="SC.bin", chunk_size = 8, write_vector = false, category = "category1", field_size = 10,
    input_values = SC_data 
  },
  -- in this testcase, input values are written to binary file I8.bin.
  { name = "valid I8", field_type = 'I8', filename="I8.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = I8_data 
  },
  --to make sure I8.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from I8.bin, and compare the values in binary file to values got by reading vector
  { name = "valid I8 read", field_type = 'I8', filename="I8.bin", chunk_size = 8, write_vector = false, category = "category1",
    input_values = I8_data 
  },
  -- valid b1 testcases with number of elements is multiple of 8
  -- in this testcase, input values are written to binary file B1.bin.
  { name = "valid B1", field_type = 'B1', filename="B1.bin", chunk_size = 8, write_vector = true, category = "category2",
    input_values = B1_data 
  },
  --to make sure B1.bin is present, run the testcase with write_vector = true first
  -- Vector read the values from B1.bin, and compare the values in binary file to values got by reading vector
  { name = "valid B1 read", field_type = 'B1', filename="B1.bin", chunk_size = 8, write_vector = false, category = "category2", 
    input_values = B1_data 
  },
  -- valid b1 testcases with number of elements is not multiple of 8
  { name = "second valid B1  ", field_type = 'B1', filename="B1.bin", chunk_size = 8, write_vector = true, category = "category2",
    input_values = B1_odd_data 
  },
  --to make sure B1.bin is present, run the testcase with write_vector = true first
  -- valid b1 testcases with number of elements is not multiple of 8
  { name = "second valid B1 read", field_type = 'B1', filename="B1.bin", chunk_size = 8, write_vector = false, category = "category2", 
    input_values = B1_odd_data 
  },
  -- error testcases
  -- field type not present
  { name = "null field type", filename = "I1.bin", write_vector = true, category = "category3",
    input_values = I1_data 
  },
  -- input argument to vector not table
  { name = "input argument not table", input_argument = "type not table", category = "category3"  
  },
  -- no generator input, no filename input and write vector not present 
  { name = "No write_vector filename generator", field_type = 'I4', category = "category3"
  },
  -- testcase in which the input values are not materialized.
  { name = "non materialized", field_type = 'I1', filename="I1.bin", chunk_size = 8, write_vector = true, category = "category1",
    input_values = I1_data, non_materialized = true
  },
  -- field size provided for I1 q_type
  { name = "field_size for I1", filename = "I1.bin", field_type = 'I1', write_vector = true, category = "category3",
    input_values = I1_data, field_size = 5  
  },
  -- field size provided for I2 q_type
  { name = "field_size for I2", filename = "I2.bin", field_type = 'I2', write_vector = true, category = "category3",
    input_values = I2_data, field_size = 5  
  },
  -- field size provided for I4 q_type
  { name = "field_size for I4", filename = "I4.bin", field_type = 'I4', write_vector = true, category = "category3",
    input_values = I4_data, field_size = 5  
  },
  -- field size provided for I8 q_type
  { name = "field_size for I8", filename = "I8.bin", field_type = 'I8', write_vector = true, category = "category3",
    input_values = I8_data, field_size = 5  
  },
  -- field size provided for F4 q_type
  { name = "field_size for F4", filename ="F4.bin", field_type = 'F4', write_vector = true, category = "category3",
    input_values = F4_data, field_size = 5  
  },
  -- field size provided for F8 q_type
  { name = "field_size for F8", filename = "F8.bin", field_type = 'F8', write_vector = true, category = "category3",
    input_values = F8_data, field_size = 5  
  },
   -- incorrect field type provided 
  { name = "invalid field_type", filename = "I3.bin", field_type = 'I3', write_vector = true, category = "category3",
    input_values = F8_data, field_size = 5  
  },

  
}
