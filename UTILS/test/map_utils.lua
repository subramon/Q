local err = require 'Q/UTILS/lua/error_code'

-- In this file, all the testcases are written in the format
-- name = <name of testcase>, category = <category_number>, metadata = <metadata table>, output_regex = <expected_output>,
-- They are added as a row in the below LUA table.
-- category1 - error code testcase
-- category2 - positive testcase

return { 
      -- testcase with valid field values
      { testcase_number = 1, name = "valid bool values in all fields", category = "category2", 
        metadata = { 
                    { name = "col1", qtype = "SV", dict = "D1", is_dict = "false", add = "true", has_nulls =                      "true" },
                   }
      },
      
      -- is_dict with invalid value
      { testcase_number = 2, name = "dummy value in is_dict field", category = "category1",                 
        metadata = { 
                    { name = "col1", qtype ="SV", dict = "D1", is_dict = "dummy_value", add = true, has_nulls                      = true },
                   },
        output_regex = "Invalid value in metadata for boolean field is_dict"
      },
      -- add with invalid value
      { testcase_number = 3, name = "dummy value in add field", category = "category1", 
        metadata = { 
                    { name = "col1", qtype ="SV", dict = "D1", is_dict = false, add = "dummy_value", has_nulls                      = true }
                   },
        output_regex = "Invalid value in metadata for boolean field add"
      },
      -- has_nulls with invalid values
      { testcase_number = 4, name = "dummy value in has_nulls field", category = "category1",                 
        metadata = {
                    { name = "col2", qtype = "I4", has_nulls = "dummy_value" } 
                   },
        output_regex = "Invalid value in metadata for boolean field has_nulls"
      }
}