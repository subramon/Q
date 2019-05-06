--[[ Guideline for adding new testcases in this file
File : meta_data.lua
In this file, all the testcases are written in the format
<meta file>, <output_regex>
They are added as a row in the below LUA table.
<meta_file> is the name of metadata file used. It can be a valid metadata or invalid metadata.
Names of valid metadata are prefixed by gm_ . Names of invalid metadata are prefixed by bm_.
In case of invalid metadata, output_regex has to be specified in the below table.
Because validate_metadata function is expected to return a global error in case, input is invalid metadata.
In case of valid metadata, no output_regex is required.
For all the error codes , refer to UTILS/lua/error_codes.lua
In case, you want to add a test case with a new error code, add the error code in the UTILS/lua/error_codes.lua file.
--]]


local g_err = require 'Q/UTILS/lua/error_code'

return {
  -- name field is missing in metadata
  { meta = "bm_name_missing.lua", output_regex = "Column 1-" .. g_err.METADATA_NAME_NULL },
  -- name field is missing in metadata
  { meta = "bm_name_null.lua", output_regex = "Column 1-" .. g_err.METADATA_NAME_NULL },
  -- type of metadata is not table
  { meta = "bm_not_table1.lua", output_regex = g_err.METADATA_TYPE_TABLE },
  -- type of metadata is not table
  { meta = "bm_not_table2.lua", output_regex = g_err.METADATA_TYPE_TABLE },
  -- qtype field is missing in metadata
  { meta = "bm_type_missing.lua", output_regex = "Column 1-" .. g_err.METADATA_TYPE_NULL },
  -- invalid qtype specified in metadata
  { meta = "bm_type_not_qtype.lua", output_regex = "Column 1-" .. g_err.INVALID_QTYPE },
  -- no metadata given i.e. metadata type is nil 
  { meta = "bm_nil.lua", output_regex = g_err.METADATA_TYPE_TABLE },
  -- metadata have duplicate column names 
  { meta = "bm_same_cols_name.lua", output_regex = "Column 2-" .. g_err.DUPLICATE_COL_NAME },
  -- max_width field missing in metadata for SV column
  { meta = "bm_SV1.lua", output_regex = g_err.MAX_WIDTH_NULL_ERROR },
  -- max_width field of SV having value greater than valid max_width 
  { meta = "bm_SV2.lua", output_regex = "Column 1-" .. g_err.INVALID_WIDTH_SV },
  -- dictionary not present in SV metadata
  { meta = "bm_SV3.lua", output_regex = "Column 1-" .. g_err.DICTIONARY_NOT_PRESENT },
  -- is_dict field in metadata cannot be null
  { meta = "bm_SV4.lua", output_regex = "Column 1-" .. g_err.IS_DICT_NULL },
  -- is_dict field in metadata cannot be other than true or false
  { meta = "bm_SV5.lua", output_regex = "Column 1-" .. g_err.INVALID_IS_DICT_BOOL_VALUE },
  -- if is_dict true than add should be either true or false
  { meta = "bm_SV6.lua", output_regex = "Column 1-" .. g_err.INVALID_ADD_BOOL_VALUE },
  
  
  -- width field missing in metadata for SC column
  { meta = "bm_SC1.lua", output_regex = g_err.MAX_WIDTH_NULL_ERROR },
  -- width field of SC column having value greater than valid width 
  { meta = "bm_SC2.lua", output_regex = "Column 1-" .. g_err.INVALID_WIDTH_SC },
  -- width field of SC column having value smaller than valid width 
  { meta = "bm_SC3.lua", output_regex = "Column 1-" .. g_err.INVALID_WIDTH_SC },
  
  -- bad double quote mismatch, string not ending properly with double quotes
  { meta = "gm_double_quotes_mismatch.lua" },
  -- end of line character in file contents
  { meta = "gm_eoln.lua" },
  -- valid escaping character in SV column
  { meta = "gm_valid_escape_char.lua" },
  -- escaping character in SV field is missing  
  { meta = "gm_missing_escape_char.lua" },
  -- column count in csv file are less than column count specified in metadata 
  { meta = "gm_column_is_more.lua" },
  -- column count in csv file are more than column count specified in metadata 
  { meta = "gm_column_is_less.lua" },
  -- number of columns not same on each csv line
  { meta = "gm_column_not_same.lua" },
  -- testing whether load is successfully works or not
  { meta = "gm_load_success.lua" },
  -- testing whether valid bin files size are generated or not
  { meta = "gm_valid_bin_file_size.lua" },
  -- null value in not null field column 1
  { meta = "gm_nil_in_not_nil_field1.lua" },
  -- null value in not null field column 2
  { meta = "gm_nil_in_not_nil_field2.lua" },
  -- no null value in null field
  { meta = "gm_no_nil_in_nil_field.lua" },
  -- valid I1 type contents 
  { meta = "gm_valid_I1.lua" },
  -- valid I2 type contents 
  { meta = "gm_valid_I2.lua" },
  -- valid I4 type contents 
  { meta = "gm_valid_I4.lua" },
  -- valid I8 type contents 
  { meta = "gm_valid_I8.lua" },
  -- valid F4 type contents 
  { meta = "gm_valid_F4.lua" },
  -- valid F8 type contents 
  { meta = "gm_valid_F8.lua" },
  -- valid SC type contents 
  { meta = "gm_valid_SC.lua" },
  -- fixed size string is greater than allowed width in SC
  { meta = "gm_SC_more_data_than_size.lua" },
    -- valid SV type contents 
  { meta = "gm_valid_SV.lua" },
  -- valid dict exists specified in is_dict field of metadata
  { meta = "gm_valid_SV_dict_exists_add_true.lua" },
  -- I1 overflow test
  { meta = "gm_I1_overflow.lua" },
  -- I2 overflow test
  { meta = "gm_I2_overflow.lua" },
  -- I4 overflow test
  { meta = "gm_I4_overflow.lua" },
  -- I8 overflow test
  { meta = "gm_I8_overflow.lua" },
  -- testing for invalid data ( i.e. string in I1 field )
  { meta = "gm_bad_str_in_I1.lua" },
  -- testing for valid whole csv row null test
  { meta = "gm_whole_row_null.lua" },
  -- test valid null data in null allowed I4 column 
  { meta = "gm_nil_data_I4.lua" },
  -- test valid null data in null allowed SV column 
  { meta = "gm_nil_data_SV.lua" },
  -- no null in allowed null column so testing for file deletion test of _nn file
  { meta = "gm_nil_data_file_deletion.lua" },
  -- _G["Q_META_DATA_DIR"] points to null
  { meta = "gm_metadata_dir_env_nil.lua"},
  -- _G["Q_META_DATA_DIR"] points to invalid directory 
  { meta = "gm_metadata_dir_env_invalid.lua"},
  -- _G["Q_DATA_DIR"] points to null
  { meta = "gm_data_dir_env_nil.lua"},
 -- _G["Q_DATA_DIR"] points to invalid directory 
  { meta = "gm_data_dir_env_invalid.lua"} 
}


