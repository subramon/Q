--[[ Guideline for adding new testcases in this file
File : map_metadata_data.lua
In this file, all the testcases are written in the format
meta = <meta file>, data = <csv_file>, category = <category_number>, output_regex = <expected_output>
They are added as a row in the below LUA table.
category1 - error code testcases
category2 - output of load_csv is 1 column
category3 - output of load_csv is more than 1 column
category4 - bin size testcase
category5 - null file deletion testcase
category6 - invalid enviornment variable testcase
For all the error codes , refer to UTILS/lua/error_codes.lua
In case, you want to add a test case with a new error code, add the error code in the UTILS/lua/error_codes.lua file.
--]]

local g_err = require 'Q/UTILS/lua/error_code'

return { 
  -- error messages test cases
  -- falls in category 1
  
    -- testing whether csv input file exists
    { testcase_no = 1, meta= "gm_input_file_not_found.lua",data= "dummy.csv", category= "category1", 
      output_regex= g_err.INPUT_FILE_NOT_FOUND, name = "input file not found", opt_args = { use_accelerator = false } },
    -- testing whether csv input file is not empty
    { testcase_no = 2, meta= "gm_input_file_not_found.lua",data= "file_empty.csv", category= "category1", 
      output_regex= g_err.INPUT_FILE_EMPTY, name = "input file empty", opt_args = { use_accelerator = false } },
    -- bad double quote mismatch, string not ending properly with double quotes
    { testcase_no = 3, meta= "gm_double_quotes_mismatch.lua",data= "bad_quote_mismatch.csv", category= "category1", 
      output_regex= g_err.INVALID_INDEX_ERROR, name = "double_quotes_mistmatch", opt_args = { use_accelerator = false } },
    -- testing whether appropriate number of commas are given in the csv file
    { testcase_no = 4, meta= "gm_invalid_2D.lua",data= "invalid_2D.csv", category= "category1", 
      output_regex= g_err.NULL_IN_NOT_NULL_FIELD, name = "invalid 2D data", opt_args = { use_accelerator = false } },
    -- column count in csv file are less than column count specified in metadata 
    { testcase_no = 5, meta= "gm_column_is_more.lua", data= "I2_I2_SV_3_4.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "columns_are_more", opt_args = { use_accelerator = false }  },
    -- column count in csv file are more than column count specified in metadata 
    { testcase_no = 6, meta= "gm_column_is_less.lua", data= "I2_I2_SV_3_4.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "columns_are_less", opt_args = { use_accelerator = false } },
    -- number of columns not same on each csv line
    { testcase_no = 7, meta="gm_column_not_same.lua",data= "bad_col_data_mismatch_each_line.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "column_not_same", opt_args = { use_accelerator = false } },
    -- null value in not null field column 1
    { testcase_no = 8, meta= "gm_nil_in_not_nil_field1.lua", data= "I4_2_null.csv", category= "category1",
      output_regex= g_err.NULL_IN_NOT_NULL_FIELD, name = "nil_in_not_nil_field1", opt_args = { use_accelerator = false } },
    -- null value in not null field column 2
    { testcase_no = 9, meta= "gm_nil_in_not_nil_field2.lua", data= "I4_2_4_null.csv", category= "category1", 
      output_regex= g_err.NULL_IN_NOT_NULL_FIELD, name = "nil_in_not_nil_field2", opt_args = { use_accelerator = false } },
    -- I1 qtype overflow test
    { testcase_no = 10, meta= "gm_I1_overflow.lua", data= "I1_overflow.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "I1_overflow", opt_args = { use_accelerator = false } },
    -- I2 qtype overflow test
    { testcase_no = 11, meta= "gm_I2_overflow.lua", data= "I2_overflow.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "I2_overflow", opt_args = { use_accelerator = false } },
    -- I4 qtype overflow test
    { testcase_no = 12, meta= "gm_I4_overflow.lua", data= "I4_overflow.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "I4_overflow", opt_args = { use_accelerator = false } },
    -- I8 qtype overflow test
    { testcase_no = 13, meta= "gm_I8_overflow.lua", data= "I8_overflow.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "I8_overflow", opt_args = { use_accelerator = false } },
    -- testing for invalid data ( i.e. string in I1 field )
    { testcase_no = 14, meta= "gm_bad_str_in_I1.lua", data= "bad_string_in_I1.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "bad_str_in_I1", opt_args = { use_accelerator = false } },
    -- escaping character in SV field is missing  
    { testcase_no = 15, meta = "gm_missing_escape_char.lua", data = "missing_escape_char.csv", category= "category1",
      output_regex= g_err.INVALID_INDEX_ERROR, name = "missing_escape_char", opt_args = { use_accelerator = false } },
    { testcase_no = 16, meta = "gm_invalid_SC_width.lua", data = "invalid_SC_width.csv", category= "category1",
      output_regex= g_err.STRING_TOO_LONG, name = "SC width value is invalid", opt_args = { use_accelerator = false } },
    
    -- category 2 testcases contains only 1 Column
    -- No last line in CSV file
    { testcase_no = 17, meta = "gm_valid_I1.lua", data = "I1_valid_no_last_line.csv", category= "category2",
      output_regex = {-128,0,127,11}, name = "valid I1 with no last line"  },
    -- CSV file with valid I1 values
    { testcase_no = 18, meta = "gm_valid_I1.lua", data = "I1_valid.csv", category= "category2",
      output_regex = {-128,0,127,11}, name = "valid_I1_type"  },
    -- CSV file with valid I2 values
    { testcase_no = 19, meta = "gm_valid_I2.lua", data = "I2_valid.csv", category= "category2",
      output_regex = {-32768,0,32767,11}, name = "valid_I2_type"  },
    -- CSV file with valid I4 values
    { testcase_no = 20, meta = "gm_valid_I4.lua", data = "I4_valid.csv", category= "category2",
      output_regex = {-2147483648,0,2147483647,11}, name = "valid_I4_type"  }, 
    -- CSV file with valid I8 values
    { testcase_no = 21, meta = "gm_valid_I8.lua", data = "I8_valid.csv", category= "category2",
      output_regex = {-9223372036854775808,0,9223372036854775807,11}, name = "valid_I8_type" },
    -- CSV file with valid F4 values
    { testcase_no = 22, meta = "gm_valid_F4.lua", data = "F4_valid.csv", category= "category2",
      output_regex = {-90000000.00,0,900000000.00,11}, name = "valid_F4_type"  },
    -- CSV file with valid F8 values
    { testcase_no = 23, meta = "gm_valid_F8.lua", data = "F8_valid.csv", category= "category2",
      output_regex = {-9.58,0,9.58,11}, name = "valid_F8_type" },
    -- CSV file with special characters
    -- the expected output is abc,\" 
    { testcase_no = 24, meta = "gm_valid_escape_character.lua", data = "valid_escape_character.csv", category= "category2",
      output_regex = {'abc,\\"'}, name = "valid_escape_character" },
    
    -- CSV file with valid SC type   
    { testcase_no = 25, meta = "gm_valid_SC.lua", data = "SC_valid.csv", category= "category2",
      output_regex = {"Sampletesttestt","Stringtesttestt","Forfdbfdhfdhhff","Varcharddddddsw"}, name = "valid_SC_type" },
    --CSV file with valid SV type
    { testcase_no = 26, meta = "gm_valid_SV.lua", data = "SV_valid.csv", category= "category2",
      output_regex = {"Sample","String","For","Varchar"}, name = "valid_SC_type"  },

    -- SV type contains special character like double quotes etc
    { testcase_no = 27, meta = "gm_valid_escape_char.lua", data = "valid_escape.csv", category= "category2",
          output_regex = {"This is valid text containing \"quoted\" text and , comma ","ok","Some random valid string","valid data"},          name = "valid_escape_char" 
    },
    -- CSV file with end of line \n    
    --{ meta=  "gm_eoln.lua", data= "file_with_eol.csv", category= "category2",
    --  output_regex = {"Data having","ok","ok","ok"}, name = "file_with_end_of_line" 
    --},
    -- if Nil is not present in Nil field  
    { testcase_no = 28, meta = "gm_no_nil_in_nil_field.lua", data = "I4_valid.csv", category= "category2",
      output_regex = {-2147483648,0,2147483647,11}, name = "no_nil_in_nil_field" 
    },
    
    --{ meta = "gm_valid_SC_dict_exists_add_true.lua", data = "SV_valid.csv", category= "category2",
    --  output_regex =  {"Sample","String","For","Varchar"}, name = "valid_SC_dict_exists_add_true" 
    --},
    -- CSV file with valid B1 values
    {
      testcase_no = 29, meta = "gm_valid_B1.lua", data = "B1_valid.csv", category= "category2",
      output_regex = {1, 0, 1, 0, 1, 0, 0, 1}, name = "valid B1"  
    },
    
    -- category 3 testcases contains more than 1 Column.
    -- combination of I2, I2 and SV data type
    { testcase_no = 30, meta = "gm_load_success.lua", data = "I2_I2_SV_3_4.csv", category= "category3", 
      output_regex = {
                        {1001,1002,1003},
                        {2012,2013,2014},
                        {"Emp1","Emp2","Emp3"}
                     },
      name = "testing_load_success" 
    },
    
    -- third row is null
    { testcase_no = 31, meta = "gm_whole_row_null.lua", data = "whole_row_nil.csv", category= "category3",
      output_regex = {
                        {"hello","hii","","hey"},
                        {92514.2,9459.1,"",987548.5}
                     },
      name = "whole_row_null" 
    },
    
    -- null present in I4 datatype in CSV file
    { testcase_no = 32, meta = "gm_nil_data_I4.lua", data = "I4_2_4_null.csv", category= "category3",
      output_regex = {
                        {111,111,333,"",444},
                        {222,222,"",123,444}
                     },
      name = "nil_data_I4"
    },
    
    -- null present in SV data type in CSV file
    { testcase_no = 33, meta = "gm_nil_data_SV.lua", data = "nil_in_SV.csv", category= "category3",
      output_regex = {
                        {"hello","hii","","","hey"},
                        {92514,9459,925,987,987548}
                     },
      name = "nil_data_SV"
    },
    
    -- more than 1 column testing with B1 
    -- cols are I4 and B1
    { testcase_no = 34, meta = "gm_valid_I4_B1.lua", data = "I4_B1_valid.csv", category= "category3", 
      output_regex = {
                       {1001,1002,1003,1004,1005,1006},
                       {1,1,1,1,1,0}
                     },
      name = "testing B1 with more than one cols",
      opt_args = { use_accelerator = false }
    },
    
    -- check the size of output binary file is correct, 
    { testcase_no = 35, meta = "gm_valid_bin_file_size.lua", data = "I2_I2_SV_3_4.csv", category= "category4",
      output_regex= {12, 6, 12}, name = "valid_bin_file_size" 
    },
    
    -- if has_nulls = true, but no nulls present in CSV file, then null file should be deleted
    { testcase_no = 36, meta = "gm_nil_data_file_deletion.lua", data = "I4_valid.csv", category= "category5",
      output_regex = 1, name = "nil_data_file_deletion" 
    },
    
    -- testcases for testing elements(rows) > chunk_size
    
    -- I4 qtype values 
    -- use_accelerator by default set to true, testing load_csv C code 
    { testcase_no = 37, meta = "gm_valid_I4.lua", data = "I4_valid_more_than_chunksize.csv", 
      category= "category2_1", num_elements = 65540, name = "elements more than chunksize-I4_U_A_T" }, 
        
    -- I4 qtype values
    -- use_accelerator is set to false, testing load_csv lua code 
    { testcase_no = 38, meta = "gm_valid_I4.lua", data = "I4_valid_more_than_chunksize.csv", 
      category= "category2_1", num_elements = 65540, name = "elements more than chunksize-I4_U_A_F",
      opt_args = { use_accelerator = false } },   
       
    -- B1 qtype values; 
    -- use_accelerator by default set to true, testing load_csv C code 
    { testcase_no = 39, meta = "gm_valid_B1.lua", data = "B1_valid_more_than_chunksize.csv", 
      category= "category2_1", num_elements = 65540, name = "elements more than chunksize-B1_U_A_T" },    
     
    --[[ 
    -- B1 qtype values
    -- use_accelerator is set to false, testing load_csv lua code 
    { testcase_no = 40, meta = "gm_valid_B1.lua", data = "B1_valid_more_than_chunksize.csv", 
      category= "category2_1", num_elements = 65540, name = "elements more than chunksize-B1_U_A_F",
      opt_args = { use_accelerator = false } },    
    -- ]]
       
    -- opt_args negative test cases
    
    -- opt_args is passed as string, should return an error
    { testcase_no = 41, meta = "gm_valid_I1.lua", data = "I1_valid.csv", category= "category1",
      output_regex = "opt_args must be of type table" , name = "opt_args passed as type string", 
      opt_args = "string" },
    
    -- opt_args is passed as integer, should return an error
    { testcase_no = 42, meta = "gm_valid_I1.lua", data = "I1_valid.csv", category= "category1",
      output_regex = "opt_args must be of type table" , name = "opt_args passed as type integer", 
      opt_args = 1 },
    
    -- opt_args--> use_accelerator is passed as string, should return an error
    { testcase_no = 43, meta = "gm_valid_I1.lua", data = "I1_valid.csv", category= "category1",
      output_regex = "type of use_accelerator is not boolean" , name = "use_accelerator passed as type string", 
      opt_args = { use_accelerator = "string" } },
    
    -- opt_args--> use_accelerator is passed as integer, should return an error
    { testcase_no = 44, meta = "gm_valid_I1.lua", data = "I1_valid.csv", category= "category1",
      output_regex = "type of use_accelerator is not boolean" , name = "use_accelerator passed as type integer", 
      opt_args = { use_accelerator = 1 }  },

    -- opt_args--> is_hdr is passed as string, should return an error
    { testcase_no = 45, meta = "gm_valid_I1.lua", data = "I1_valid.csv", category= "category1",
      output_regex = "type of is_hdr is not boolean" , name = "is_hdr passed as type string", 
      opt_args = { is_hdr = "string" } },
    
    -- opt_args--> is_hdr is passed as integer, should return an error
    { testcase_no = 46, meta = "gm_valid_I1.lua", data = "I1_valid.csv", category= "category1",
      output_regex = "type of is_hdr is not boolean" , name = "is_hdr passed as type integer", 
      opt_args = { is_hdr = 1 }  },
    
}
