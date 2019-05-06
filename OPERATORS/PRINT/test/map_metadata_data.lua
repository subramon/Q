--[[ Guideline for adding new testcases in this file
File : map_metadata_data.lua
In this file, all the testcases are written in the format
meta = <meta file>, data = <input csv_file to load>, csv_file = <output csv file of print> category = <category_number>
They are added as a row in the below LUA table.
category1 - match csv file in data field with csv file in csv_file field
category1_1 - test-case for testing elements(rows) > chunk_size 
            - These are test-cases with large csv files so generating it using generate_csv() function
category1_2 - test-case for F4 and F8 qtype
            - their actual and expected output comparison is done using vveq and sum operator
category1_4 - positive testcase of multiple columns
            - matches output_regex(expected_value) with print_csv opfile contents  
category2 - invalid filter input to print_csv. output_regex is error code in these testcases
category3 - bit vector is B1
category4 - bit vector is I4. output error expected
category5 - output csv file from print_csv should be consumable to load_csv
category6 - Range filter testcase
For all the error codes , refer to UTILS/lua/error_codes.lua
In case, you want to add a test case with a new error code, add the error code in the UTILS/lua/error_codes.lua file.
--]]
local g_err = require 'Q/UTILS/lua/error_code'

return { 
  -- testcase for printing single column content
  { testcase_no = 1, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category1", name= "single_col", output_regex = "1001\n1002\n1003\n1004\n", opt_args = { opfile = "single_col.csv" } },
  -- testcase for printing multiple column contents
  { testcase_no = 2, meta = "gm_multi_col.lua",  data ="multi_col_file.csv", category = "category1", name= "multiple_col", output_regex = "1001,1\n1002,2\n1003,3\n1004,4\n",  opt_args = { opfile = "multi_col.csv", print_order = {"empid", "yoj"} } },
  -- checking for valid I1 column contents
  { testcase_no = 3, meta = "gm_print_I1.lua", data ="sample_I1.csv", category = "category1", name= "print_I1_type", output_regex = "12\n123\n50\n111\n", opt_args = { opfile = "print_I1.csv"} },
  -- checking for valid I2 column contents
  { testcase_no = 4, meta = "gm_print_I2.lua", data ="sample_I2.csv", category = "category1", name= "print_I2_type", output_regex = "1002\n123\n2312\n2131\n", opt_args = { opfile = "print_I2.csv" }},
  -- checking for valid I4 column contents
  { testcase_no = 5, meta = "gm_print_I4.lua", data ="sample_I4.csv", category = "category1", name= "print_I4_type", output_regex = "1002\n123\n2312\n2131\n", opt_args = { opfile = "print_I4.csv" }},
  -- checking for valid I8 column contents
  { testcase_no = 6, meta = "gm_print_I8.lua", data ="sample_I8.csv", category = "category1", name= "print_I8_type", output_regex = "1002\n123\n2312\n2131\n", opt_args = { opfile = "print_I8.csv" }},
  -- checking for valid SV column contents
  { testcase_no = 7, meta = "gm_print_SV.lua", data ="sample_varchar.csv", category = "category1", name= "print_SV_type", output_regex = "Sample\nString\nFor\nVarchar\n", opt_args = { opfile = "print_SV.csv" } },
  -- checking for valid SC column contents
  { testcase_no = 8, meta = "gm_print_SC.lua", data ="fix_size_string.csv", category = "category1", name= "print_SC_type", output_regex = "Hiihello\nbye\n", opt_args = { opfile = "print_SC.csv" } },
  -- checking for nulls in valid allowed null column
  { testcase_no = 9, meta = "gm_print_null_I4.lua", data ="sample_null_I4.csv", category = "category1",
    name= "print_I4_null", output_regex = "1002\n\n2312\n2131\n", opt_args = { opfile = "print_null_I4.csv" } },
  
  -- testing whether filter is a table
  { testcase_no = 10, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category2",
    output_regex = g_err.FILTER_NOT_TABLE_ERROR, name = "Filter_type_not_table",
    opt_args = { filter = "test", opfile = "single_col.csv" },
  },
  -- testing whether lower bound value of filter is valid
  { testcase_no = 11, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category2",
    output_regex = g_err.INVALID_LOWER_BOUND, name = "Invalid LB",
    opt_args = { opfile = "single_col.csv", filter = { lb = -1, ub = 4 } } },
  -- lb passed is passed as string should return an error
  { testcase_no = 12, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category2",
    output_regex = g_err.INVALID_LOWER_BOUND_TYPE, name = "Invalid LB type",
    opt_args = { opfile = "single_col.csv", filter = { lb = "1" } } },
  -- ub passed is passed as string should return an error
  { testcase_no = 13, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category2",
    output_regex = g_err.INVALID_UPPER_BOUND_TYPE, name = "Invalid UB type",
    opt_args = { opfile = "single_col.csv", filter = { ub = "1" } } },
  -- testing whether upper bound value of filter is greater than lower bound value
  { testcase_no = 14, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category2",
    output_regex = g_err.UB_GREATER_THAN_LB, name = "UB greater than LB",
    opt_args = { opfile = "single_col.csv", filter = { lb = 5, ub = 4 } } },
  -- testing whether upper bound value of filter is valid
  { testcase_no = 15, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category2",
    output_regex = g_err.INVALID_UPPER_BOUND, name = "Invalid UB",
    opt_args = { opfile = "single_col.csv", filter = { lb = 1, ub = 5 } } },
  -- testing type of the filter is valid
  { testcase_no = 16, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category2",
    output_regex = g_err.FILTER_TYPE_ERROR, name = "Filter type string",
    opt_args = { opfile = "single_col.csv", filter = { where = "test" } } },
  -- testing type of the filter is valid
  { testcase_no = 17, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category2",
    output_regex = g_err.FILTER_TYPE_ERROR, name = "Filter type number",
    opt_args = { opfile = "single_col.csv", filter = { where = 1 } } },
  -- where field in filter is table and not bit vector
  { testcase_no = 18, meta = "gm_single_col.lua", data ="single_col_file.csv", 
    category = "category2", output_regex = g_err.FILTER_TYPE_ERROR, 
    name = "Filter type table", opt_args = { opfile = "single_col.csv", filter = { where = { 1 } } }
  },
  -- csv file path provided to print_csv is invalid
  { testcase_no = 19, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category2",
    output_regex = g_err.INVALID_FILE_PATH, name = "Invalid file path",
    opt_args = { opfile = "dummy/single_col.csv" } },
  
  -- this testcase, bit filter passed is of type I4
  { testcase_no = 20, meta = "gm_single_col.lua", data ="single_col_file.csv",  
    category = "category4", name="bit filter I4", output_regex = g_err.FILTER_INVALID_FIELD_TYPE, name= "bit_filter_type_I4",
    opt_args = { opfile = "single_col.csv" }},
  
  -- this testcase, bit filter passed is of type B1
  { testcase_no = 21, meta = "gm_single_col.lua", data ="single_col_file.csv", 
    category = "category3", name="bit filter B1", output_regex = "1001\n1002\n1003\n",
    opt_args = { opfile = "single_col.csv" } },
  
  -- output csv file from print_csv should be consumable to load_csv
  { testcase_no = 22, meta = "gm_csv_consumable.lua", category = "category6",
    name = "csv consumable testcase", opt_args = { opfile = "print_out_cons.csv"} }, 
  
  -- testing whether range filter outputs correct values
  { testcase_no = 23, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category5",
    output_regex = "1002\n1003\n", name = "range filter test",
    opt_args = {  opfile = "single_col.csv", filter = { lb = 1, ub = 3 } } },
  -- 
  { testcase_no = 24, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category7",  
    output_regex = "1001\n1002\n1003\n1004\n", name = "input csv file null",
    opt_args = { opfile = "" } },
  
    -- 
  { testcase_no = 25, meta = "gm_single_col.lua", data ="single_col_file.csv", category = "category8",  
    output_regex = "1001\n1002\n1003\n1004\n", name = "input csv file null",
    opt_args = { opfile = nil } },
  
  --{ meta = "gm_print_stdout.lua", data ="std_out_file.csv", csv_file = "stdout.csv"},
  
  -- testcase for testing elements(rows) > chunk_size
  -- I4 qtype values
  { testcase_no = 26, meta = "gm_single_col.lua", data = "I4_more_than_chunksize.csv",
    category = "category1_1", name= "elements more than chunksize-I4", num_elements = 65540,
    opt_args = { opfile = "print_more_than_chunksize.csv" } },
  
  { testcase_no = 27, meta = "gm_print_F4.lua", data ="sample_F4.csv", category = "category1_2",
    name= "print F4 type", opt_args = { opfile = "print_F4.csv" } },
  
  { testcase_no = 28, meta = "gm_print_F8.lua", data ="sample_F8.csv", category = "category1_2",
    name= "print F8 type", opt_args = { opfile = "print_F8.csv" } },

  -- checking for valid SV column contents with special characters like double quote, backslash etc
  { testcase_no = 29, meta = "gm_print_SV.lua", data ="sample_varchar_special_chars.csv", category = "category1_3",
    name = "print_SV_with_special_char", output_regex = "Sample\nString\n\"For\"\nVar\\char\n", 
    opt_args = { opfile = "print_SV_special_char.csv" } },
  -- checking for valid SC column contents with special characters like double quote, backslash etc
  { testcase_no = 30, meta = "gm_print_SC.lua", data ="fix_size_string_special_chars.csv", category = "category1_3", name= "print_SC_with_special_char", output_regex = "Hiihello\nb\"y\"\\e\n", opt_args = { opfile = "print_SC_special_char.csv" } },
  
  -- opt_args negative test cases

  -- opt_args is passed as string, should return an error 
  { testcase_no = 31, meta = "gm_single_col.lua", data = "single_col_file.csv", category = "category2",
    output_regex = g_err.INVALID_OPT_ARGS_TYPE , name = "opt_args passed as type string",
    opt_args = "string" },
  
  -- opt_args is passed as integer, should return an error
  { testcase_no = 32, meta = "gm_single_col.lua", data = "single_col_file.csv", category = "category2",
    output_regex = g_err.INVALID_OPT_ARGS_TYPE , name = "opt_args passed as type integer",
    opt_args = 1 },
  
  -- opt_args--> print_order is passed as string, should return an error 
  { testcase_no = 33, meta = "gm_single_col.lua", data = "single_col_file.csv", category = "category2",
    output_regex = g_err.INVALID_PRINT_ORDER_TYPE , name = "print_order passed as type string",
    opt_args = { print_order = "string" } },

  -- opt_args--> print_order is passed as integer, should return an error
  { testcase_no = 34, meta = "gm_single_col.lua", data = "single_col_file.csv", category = "category2",
    output_regex = g_err.INVALID_PRINT_ORDER_TYPE , name = "print_order passed as type integer",
    opt_args = { print_order = 1 } },
  --[[
  -- opt_args--> print_order values are of type integer, should return an error
  { testcase_no = 34, meta = "gm_single_col.lua", data = "single_col_file.csv", category = "category2",
    output_regex ="sort_order table value is not string type" , name = "print_order values passed as integer",
    opt_args = { print_order = { 1 } } },
  ]]
 -- length of opt_args--> print_order attempted to be zero, should return an error 
  { testcase_no = 35, meta = "gm_multi_col.lua",  data ="multi_col_file.csv", category = "category2", 
    name= "length of print_order is zero", 
    output_regex = g_err.SORT_ORDER_LENGTH_ZERO,  
    opt_args = { opfile = "multi_col.csv", print_order = { } } },
 
 -- length of opt_args--> print_order attempted >(greater than) expected columns,
 -- should return an error
 { testcase_no = 36, meta = "gm_multi_col.lua",  data ="multi_col_file.csv", category = "category2", 
    name= "length of print_order greater than expected columns", 
    output_regex = g_err.SORT_ORDER_LENGTH_GT_COLS,  
    opt_args = { opfile = "multi_col.csv", print_order = { "empid", "yoj", "empname" } } },
 
 -- print_order string should match column index name
  { testcase_no = 37, meta = "gm_multi_col.lua",  data ="multi_col_file.csv", category = "category2", 
    name= "length of print_order greater than expected columns", 
    output_regex = g_err.INCORRECT_COLUMN_NAME_IN_SORT_ORDER,  
    opt_args = { opfile = "multi_col.csv", print_order = { "empid", "doj" } } },
  
 -- opt_args positive testcase: load_csv(empid, sal, yoj) print_order (empid, yoj, sal)
 -- testcase for printing multiple column contents as per valid print_order
  { testcase_no = 38, meta = "gm_valid_print_order.lua",  data = "valid_print_order.csv", 
    category = "category1_4", name = "multiple_col", 
    output_regex = "1001,2015,30000\n1002,2016,35000\n1003,2017,40000\n1004,2018,45000\n",  
    opt_args = { opfile = "multi_col.csv", print_order = {"empid", "yoj", "sal"} } },  
  
}

      
     
    
    
