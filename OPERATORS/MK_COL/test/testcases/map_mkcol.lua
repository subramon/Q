--[[ Guideline for adding new testcases in this file
File : map_mkcol.lua
In this file, all the testcases are written in the format
name = <testcase name>, input = <input values given in lua table>, qtype = <type of data e.g. I1, I4 etc>, category = <category_number>
They are added as a row in the below LUA table.
category1 - error code testcases
category2 - positive testcases
category2_1 - testcase for testing elements(rows) > chunk_size
            - same as category2 testcases, just the input table is large in length
            - this input table is generated using generate_input_table()
            - the generate_input_table() function is in test_mk_col.lua file
            - once this table is generated these testcases can be categorized into category2
category3 - positive I8 testcases, value passed to scalar must be of type string
          - max and min lua number testcase
          - validating vector values using print_csv operator
          - as lua can't handle max and min lua number(e+15)
For all the error codes , refer to UTILS/lua/error_codes.lua
In case, you want to add a test case with a new error code, add the error code in the UTILS/lua/error_codes.lua file.
--]]

local g_err = require 'Q/UTILS/lua/error_code'

return { 
  -- error messages test cases
  -- falls in category 1
  
  -- compare input values with value written in binary file
  -- category 2 testcases
  
  -- simple I1 values given to mk_col
  { testcase_no = 1, name = "simple I1 values", input = { 1, 3, 5}, qtype = "I1", category= "category2"},
  
  -- simple I2 values given to mk_col
  { testcase_no = 2, name = "simple I2 values", input = { 1, 3, 5}, qtype = "I2", category= "category2"},

-- simple I4 values given to mk_col
  { testcase_no = 3, name = "simple I4 values", input = { 1, 3, 5}, qtype = "I4", category= "category2"},

-- simple I8 values given to mk_col
  { testcase_no = 4, name = "simple I8 values", input = { 1, 3, 5}, qtype = "I8", category= "category2"},

-- simple I4 values given to mk_col
  { testcase_no = 5, name = "simple F4 values", input = { 1.12, 3.20, 5.30}, qtype = "F4", category= "category2", precision = 2 },

-- simple I8 values given to mk_col
  { testcase_no = 6, name = "simple F8 values", input = { 1.1, 3.2, 5.3}, qtype = "F8", category= "category2",  precision = 1 },

-- simple B1 values given to mk_col
  { testcase_no = 7, name = "simple B1 values", input = { 0, 1, 1, 0}, qtype = "B1", category= "category2"},

-- border I1 values given to mk_col
  { testcase_no = 8, name = "border I1 values", input = { 127, -128}, qtype = "I1", category= "category2"},

-- border I2 values given to mk_col
  { testcase_no = 9, name = "border I2 values", input = { 32767, -32768}, qtype = "I2", category= "category2"},

-- border I4 values given to mk_col
  { testcase_no = 10, name = "border I4 values", input = { 2147483647, -2147483648}, qtype = "I4", category= "category2"},
  
-- Commenting below two testcases as below numbers get converted in exponential form like 9.0071...e+17 when received in Scalar code
-- Scalar is failing while dealing with numbers in exponential form (it internally calls txt_to_qtype, which fails)
-- TODO: revisit this case
--  { testcase_no = 11, name = "maximum lua number", input = {9007199254740991}, qtype = "I8", category= "category2"},
  
--  { testcase_no = 12, name = "minimum lua number", input = {-9007199254740991}, qtype = "I8", category= "category2"},

  { testcase_no = 13, name = "maximum lua number", input = {9007199254740992}, qtype = "I8", 
    category= "category1", output_regex = "bad value for Scalar" },
  
  { testcase_no = 14, name = "minimum lua number", input = {-9007199254740992}, qtype = "I8", 
    category= "category1", output_regex = "bad value for Scalar" },

-- border I8 values given to mk_col
  { testcase_no = 15, name = "border I8 values", input = { "9223372036854775807"}, qtype = "I8",
    category= "category3" },

  { testcase_no = 16, name = "border I8 values", input = { "-9223372036854775808"}, qtype = "I8",
    category= "category3" },
  
  -- Overflow I1 values given to mk_col
  { testcase_no = 17, name = "Overflow I1 values", input = { 128 }, qtype = "I1", category= "category1",
    output_regex = "bad value for Scalar" },
  
  -- Overflow I1 values given to mk_col
  { testcase_no = 18, name = "Overflow I1 values", input = { -129 }, qtype = "I1", category= "category1",
    output_regex = "bad value for Scalar" },
  
  -- Overflow I2 values given to mk_col
  { testcase_no = 19, name = "Overflow I2 values", input = { 32768 }, qtype = "I2", category= "category1",
    output_regex = "bad value for Scalar" },
  
  -- Overflow I2 values given to mk_col
  { testcase_no = 20, name = "Overflow I2 values", input = { -32769 }, qtype = "I2", category= "category1",
    output_regex = "bad value for Scalar" },
  
  -- Overflow I4 values given to mk_col
  { testcase_no = 21, name = "Overflow I4 values", input = { 2147483648 }, qtype = "I4", category= "category1",
    output_regex = "bad value for Scalar" },
  
  -- Overflow I4 values given to mk_col
  { testcase_no = 22, name = "Overflow I4 values", input = { -2147483649 }, qtype = "I4", category= "category1",
    output_regex = "bad value for Scalar" },

  -- Overflow I8 values given to mk_col
  { testcase_no = 23, name = "border I8 values", input = { "9223372036854775808"}, qtype = "I8",
    category= "category1", output_regex = "bad value for Scalar" },

  { testcase_no = 24, name = "border I8 values", input = { "-9223372036854775809"}, qtype = "I8",
    category= "category1", output_regex = "bad value for Scalar" },

  -- Overflow I4 values given to mk_col
  -- mk_col should validate inputs should be of B1 type ( 0 or 1 )
  { testcase_no = 25, name = "Invalid B1 values", input = { 2 }, qtype = "B1", category= "category1",
    output_regex = "bad value for Scalar" },
  
  -- testcase for testing elements(rows) > chunk_size
  -- I4 qtype values
  { testcase_no = 26, name= "elements more than chunksize-I4", category = "category2_1",
    qtype= "I4", num_elements = 65540 },
}
