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
    { meta= "gm_input_file_not_found.lua",data= "dummy.csv", category= "category1", 
      output_regex= g_err.INPUT_FILE_NOT_FOUND, name = "input file not found" },
    -- testing whether csv input file is not empty
    { meta= "gm_input_file_not_found.lua",data= "file_empty.csv", category= "category1", 
      output_regex= g_err.INPUT_FILE_EMPTY, name = "input file empty" },
    -- bad double quote mismatch, string not ending properly with double quotes
    { meta= "gm_double_quotes_mismatch.lua",data= "bad_quote_mismatch.csv", category= "category1", 
      output_regex= g_err.INVALID_INDEX_ERROR, name = "double_quotes_mistmatch" },
    -- testing whether appropriate number of commas are given in the csv file
    { meta= "gm_invalid_2D.lua",data= "invalid_2D.csv", category= "category1", 
      output_regex= g_err.NULL_IN_NOT_NULL_FIELD, name = "invalid 2D data" },
    -- column count in csv file are less than column count specified in metadata 
    { meta= "gm_column_is_more.lua", data= "I2_I2_SV_3_4.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "columns_are_more"  },
    -- column count in csv file are more than column count specified in metadata 
    { meta= "gm_column_is_less.lua", data= "I2_I2_SV_3_4.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "columns_are_less"  },
    -- number of columns not same on each csv line
    { meta="gm_column_not_same.lua",data= "bad_col_data_mismatch_each_line.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "column_not_same"  },
    -- null value in not null field column 1
    { meta= "gm_nil_in_not_nil_field1.lua", data= "I4_2_null.csv", category= "category1",
      output_regex= g_err.NULL_IN_NOT_NULL_FIELD, name = "nil_in_not_nil_field1"  },
    -- null value in not null field column 2
    { meta= "gm_nil_in_not_nil_field2.lua", data= "I4_2_4_null.csv", category= "category1", 
      output_regex= g_err.NULL_IN_NOT_NULL_FIELD, name = "nil_in_not_nil_field2"  },
    -- I1 qtype overflow test
    { meta= "gm_I1_overflow.lua", data= "I1_overflow.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "I1_overflow"  },
    -- I2 qtype overflow test
    { meta= "gm_I2_overflow.lua", data= "I2_overflow.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "I2_overflow"  },
    -- I4 qtype overflow test
    { meta= "gm_I4_overflow.lua", data= "I4_overflow.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "I4_overflow" },
    -- I8 qtype overflow test
    { meta= "gm_I8_overflow.lua", data= "I8_overflow.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "I8_overflow"   },
    -- testing for invalid data ( i.e. string in I1 field )
    { meta= "gm_bad_str_in_I1.lua", data= "bad_string_in_I1.csv", category= "category1",
      output_regex= g_err.INVALID_DATA_ERROR, name = "bad_str_in_I1"  },
    -- escaping character in SV field is missing  
    { meta = "gm_missing_escape_char.lua", data = "missing_escape_char.csv", category= "category1",
      output_regex= g_err.INVALID_INDEX_ERROR, name = "missing_escape_char" },
    { meta = "gm_invalid_SC_width.lua", data = "invalid_SC_width.csv", category= "category1",
      output_regex= g_err.STRING_GREATER_THAN_SIZE, name = "SC width value is invalid" },
 
    -- category 2 testcases contains only 1 Column
    -- No last line in CSV file
    { meta = "gm_valid_I1.lua", data = "I1_valid_no_last_line.csv", category= "category2",
      output_regex = {-128,0,127,11}, name = "valid I1 with no last line"  },
    -- CSV file with valid I1 values
    { meta = "gm_valid_I1.lua", data = "I1_valid.csv", category= "category2",
      output_regex = {-128,0,127,11}, name = "valid_I1_type"  },
    -- CSV file with valid I2 values
    { meta = "gm_valid_I2.lua", data = "I2_valid.csv", category= "category2",
      output_regex = {-32768,0,32767,11}, name = "valid_I2_type"  },
    -- CSV file with valid I4 values
    { meta = "gm_valid_I4.lua", data = "I4_valid.csv", category= "category2",
      output_regex = {-2147483648,0,2147483647,11}, name = "valid_I4_type"  }, 
    -- CSV file with valid I8 values
    { meta = "gm_valid_I8.lua", data = "I8_valid.csv", category= "category2",
      output_regex = {-9223372036854775808,0,9223372036854775807,11}, name = "valid_I8_type" },
    -- CSV file with valid F4 values
    { meta = "gm_valid_F4.lua", data = "F4_valid.csv", category= "category2",
      output_regex = {-90000000.00,0,900000000.00,11}, name = "valid_F4_type"  },
    -- CSV file with valid F8 values
    { meta = "gm_valid_F8.lua", data = "F8_valid.csv", category= "category2",
      output_regex = {-9.58,0,9.58,11}, name = "valid_F8_type" },
    -- CSV file with special characters
    { meta = "gm_valid_escape_character.lua", data = "valid_escape_character.csv", category= "category2",
      output_regex = {'abc,\\"'}, name = "valid_escape_character" },
    
    -- CSV file with valid SC type   
    { meta = "gm_valid_SC.lua", data = "SC_valid.csv", category= "category2",
      output_regex = {"Sampletesttestt","Stringtesttestt","Forfdbfdhfdhhff","Varcharddddddsw"}, name = "valid_SC_type" },
    --CSV file with valid SV type
    { meta = "gm_valid_SV.lua", data = "SV_valid.csv", category= "category2",
      output_regex = {"Sample","String","For","Varchar"}, name = "valid_SC_type"  },

    -- SV type contains special character like double quotes etc
    { meta = "gm_valid_escape_char.lua", data = "valid_escape.csv", category= "category2",
          output_regex = {"This is valid text containing \"quoted\" text and , comma ","ok","Some random valid string","valid data"},          name = "valid_escape_char" 
    },
    -- CSV file with end of line \n    
    --{ meta=  "gm_eoln.lua", data= "file_with_eol.csv", category= "category2",
    --  output_regex = {"Data having","ok","ok","ok"}, name = "file_with_end_of_line" 
    --},
    -- if Nil is not present in Nil field  
    { meta = "gm_no_nil_in_nil_field.lua", data = "I4_valid.csv", category= "category2",
      output_regex = {-2147483648,0,2147483647,11}, name = "no_nil_in_nil_field" 
    },
    
    --{ meta = "gm_valid_SC_dict_exists_add_true.lua", data = "SV_valid.csv", category= "category2",
    --  output_regex =  {"Sample","String","For","Varchar"}, name = "valid_SC_dict_exists_add_true" 
    --},
    
    
    -- category 3 testcases contains more than 1 Column.
    -- combination of I2, I2 and SV data type
    { meta = "gm_load_success.lua", data = "I2_I2_SV_3_4.csv", category= "category3", 
      output_regex = {
                        {1001,1002,1003},
                        {2012,2013,2014},
                        {"Emp1","Emp2","Emp3"}
                     },
      name = "testing_load_success" 
    },
    
    -- third row is null
    { meta = "gm_whole_row_null.lua", data = "whole_row_nil.csv", category= "category3",
      output_regex = {
                        {"hello","hii","","hey"},
                        {92514.2,9459.1,"",987548.5}
                     },
      name = "whole_row_null" 
    },

    -- null present in I4 datatype in CSV file
    { meta = "gm_nil_data_I4.lua", data = "I4_2_4_null.csv", category= "category3",
      output_regex = {
                        {111,111,333,"",444},
                        {222,222,"",123,444}
                     },
      name = "nil_data_I4" 
    },
    
    -- null present in SV data type in CSV file
    { meta = "gm_nil_data_SV.lua", data = "nil_in_SV.csv", category= "category3",
      output_regex = {
                        {"hello","hii","","","hey"},
                        {92514,9459,925,987,987548}
                     },
      name = "nil_data_SV"
    },
    
    -- check the size of output binary file is correct, 
    { meta = "gm_valid_bin_file_size.lua", data = "I2_I2_SV_3_4.csv", category= "category4",
      output_regex= {12, 6, 12}, name = "valid_bin_file_size" 
    },
    
    -- if has_nulls = true, but no nulls present in CSV file, then null file should be deleted
    { meta = "gm_nil_data_file_deletion.lua", data = "I4_valid.csv", category= "category5",
      output_regex = 1, name = "nil_data_file_deletion" 
    }
}