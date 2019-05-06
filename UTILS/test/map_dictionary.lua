--[[ Guidelines for adding new testcases in this file
File : map_dictionary.lua
In this file, all the testcases are written in the format
name = <name of testcase>, category = <category_number>, meta = <meta file>, output_regex = <expected_output>,
input = <input values to the testcase>, dict_size = <expected size of dictionary>
They are added as a row in the below LUA table.
category1 - to check return type is Dictionary
category2 - error code testcase
category3 - adding valid entry into dictionary and getting valid dictionary size
category4 - getting valid index of a string from dictionary 
category5 - getting valid string stored at particular index from dictionary 
For all the error codes , refer to UTILS/lua/error_codes.lua
In case, you want to add a test case with a new error code, add the error code in the UTILS/lua/error_codes.lua file.
--]]
local err = require 'Q/UTILS/lua/error_code'

return { 
      -- checking the return of dict is dictionary
      { testcase_number = 1, name = "create dictionary", category = "category1", meta = "meta_create.lua" },
      
      -- checking of invalid dict add to a dictionary by comparing the output_regex error message
      { testcase_number = 2, name = "empty string ", category = "category2", input = "", meta = "meta_add_nil.lua", 
        output_regex = err.ADD_NIL_EMPTY_ERROR_IN_DICT  },
      
      -- checking of invalid dict add to a dictionary by comparing the output_regex error message
      { testcase_number = 3, name = "nil dict ", category = "category2", input = nil, meta = "meta_add_nil.lua", 
        output_regex = err.ADD_NIL_EMPTY_ERROR_IN_DICT  },
      
      -- checking of adding a valid dictionary entries to a dictionary and checking valid get size from a dictionary
      -- dict name = D2
      { testcase_number = 4, name = "addition of new dict ", category = "category3", meta = "meta_add_dict.lua", 
        input = {"entry1", "entry2", "entry3", "entry4", "entry5"}, dict_size = 5 },
      
      -- checking for adding an existing string ("entry5") in an existing dictionary (D2) 
      -- and checking whether valid index (5) of an existing string is returned
      -- dict name = D2 and string "entry5" maps to index 5 in testcase no. 4
      { testcase_number = 5, name = "valid addition of string", category = "category4", meta = "meta_existing_str_index.lua",
        input = {"entry5"}, output_regex = { 5 } }, 
      
      -- checking of valid get index from a dictionary
      { testcase_number = 6, name = "valid get index", category = "category4", meta = "meta_get_index.lua",
        input = {"entry1", "entry2", "entry3"}, output_regex = { 1, 2, 3 } },
      
      -- adding new as well as an existing dictionary entries to an existing dictionary ( dict which is created in testcase 4 ) 
      -- and checking its dictionary size
      -- dict name = D2
      { testcase_number = 7, name = "addition of existing dict", category = "category3", meta = "meta_add_in_existing_dict.lua", 
       input = {"entry1", "entry6", "entry7", "entry8", "entry9"}, dict_size = 9 }, 
      
      
      -- checking of valid get string from a dictionary
      { testcase_number = 8, name = "valid get string", category = "category5", meta = "meta_get_string.lua",
        input = { "entry1", "entry2", "entry3" } },
      
}
