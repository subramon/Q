g_err = {}
-- this function will be used whenever dynamic error codes will be required
--function g_err.GET_CELL_ERROR(row_idx, col_idx)
--  return "get_cell error in row " .. row_idx .. " column " .. col_idx
--end


-- load error codes
g_err.INVALID_DATA_ERROR = "Invalid data found"
g_err.INVALID_INDEX_ERROR = "Index has to be valid"
g_err.NULL_IN_NOT_NULL_FIELD = "Null value found in not null field"
--g_err.CSV_FILE_PATH_INCORRECT = "csv_file_path is not correct"
g_err.STRING_GREATER_THAN_SIZE = "contains string greater than allowed size. Please correct data or metadata."
g_err.FILE_EMPTY = "File should not be empty"
g_err.ERROR_CREATING_ACCESSING_DICT = "Error while creating/accessing dictionary for M" 
g_err.MMAP_FAILED = "Mmap failed"
--g_err.FILE_EMPTY = "File cannot be empty"
g_err.STRING_TOO_LONG = "string too long"
g_err.INPUT_FILE_NOT_FOUND = "input file not found"
g_err.INPUT_FILE_EMPTY = "input file empty"
g_err.Q_DATA_DIR_NOT_FOUND = "directory not found -- Q_DATA_DIR"
g_err.Q_META_DATA_DIR_NOT_FOUND  = "directory not found -- Q_META_DATA_DIR"
g_err.DID_NOT_END_PROPERLY = "Didn't end up properly"
g_err.BAD_NUMBER_COLUMNS = "bad number of columns on last line"
g_err.TYPE_CONVERTER_FAILED = "text converter failed for qtype"
g_err.ADD_NIL_EMPTY_ERROR_IN_DICT = "Cannot add nil or empty string in dictionary"


-- meta data codes
g_err.METADATA_NULL_ERROR = "Metadata should not be nil"
g_err.METADATA_TYPE_TABLE = "Metadata type should be table"
g_err.METADATA_NAME_NULL = " name cannot be null"
g_err.METADATA_TYPE_NULL = " type cannot be null"
g_err.INVALID_QTYPE = " type contains invalid q type"
g_err.INVALID_NN_BOOL_VALUE = " null can contain true/false only"
g_err.DUPLICATE_COL_NAME = " duplicate column name is not allowed"
g_err.SC_SIZE_MISSING = " size should be specified for fixed length strings"
g_err.SC_INVALID_SIZE = " size should be valid number"
g_err.DICT_NULL_ERROR = " dict cannot be null"
g_err.IS_LOAD_BOOL_ERROR = "is_load can contain true/false only"
g_err.IS_DICT_NULL = " is_dict cannot be null"
g_err.INVALID_IS_DICT_BOOL_VALUE = " is_dict can contain true/false only"
g_err.ADD_DICT_ERROR = " add cannot be null for dictionary which has is_dict true"
g_err.INVALID_ADD_BOOL_VALUE = " add can contain true/false if is_dict = true for SV"
g_err.INVALID_WIDTH_SC = " width for SC not valid"
g_err.INVALID_WIDTH_SV = " width for SV not valid"
g_err.DICTIONARY_NOT_PRESENT = " must specify dictionary for SV"
g_err.COLUMN_NOT_PRESENT = " must load at least one column"
g_err.COLUMN_DESC_ERROR = " column descriptor must be table"
g_err.MAX_WIDTH_NULL_ERROR = "max width null error"

-- print error codes
g_err.INPUT_NOT_TABLE = "Input is not table"
g_err.INPUT_NOT_COLUMN_NUMBER = "Input is not Column or Number"
g_err.INVALID_COLUMN_TYPE = "Invalid column field type"
g_err.COLUMN_B1_ERROR = "Column cannot be B1"
g_err.NULL_WIDTH_ERROR = "Width of Column cannot be Null"
g_err.NULL_CTYPE_ERROR = "Ctype of Column cannot be Null"
g_err.NULL_CTYPE_TO_TXT_ERROR = "Ctype to txt cannot be Null"
g_err.NULL_DICTIONARY_ERROR = "Q_Dictionay cannot be Null"
g_err.COLUMN_GET_META_ERROR = "Get meta error in Column"
g_err.COLUMN_SET_META_ERROR = "Set meta error in Column"
g_err.FILTER_NOT_TABLE_ERROR = "Filter must be a table"
g_err.FILTER_TYPE_ERROR = "Filter type must be a Vector"
g_err.FILTER_INVALID_FIELD_TYPE = "Field type of Filter should be B1"
g_err.INVALID_LOWER_BOUND = "Lower Bound less than zero"
g_err.UB_GREATER_THAN_LB = "Upper bound less than lower bound"
g_err.INVALID_UPPER_BOUND = "Upper bound greater than maximum length"
g_err.INVALID_FILE_PATH = "standard file is closed"
g_err.INVALID_UPPER_BOUND_TYPE = "type of upper is not a number"
g_err.INVALID_LOWER_BOUND_TYPE = "type of lower is not a number"

-- ffi error
g_err.FFI_NEW_ERROR = "ffi new api failed"

return g_err