local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local utils = require 'Q/UTILS/lua/test_utils'

return {
  tests = 
    {
      { 
        name = "mkcol_I1", 
        input = { {10, 20, 30, 40, 50, 60}, "I1" },
        check = function(col)
          return utils.col_as_str(col) == "10,20,30,40,50,60,"
        end
      },
      { 
        name = "mkcol_F4", 
        input = { {10.22, 20.11, 30.22, 40.11, 50.22, 60.11}, "F4" },
        check = function(col)
          print(utils.col_as_str(col))
          return utils.col_as_str(col) == "10.22,20.11,30.22,40.11,50.22,60.11,"
        end
      },
      { 
        name = "mkcol_SC", 
        input = { {"abc", "pqr"}, "SC" },
        fail = "Invalid column field type"
      },      
    }
}