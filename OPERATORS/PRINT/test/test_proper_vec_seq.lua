local Q = require 'Q'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/PRINT/test/"

local tests = {}

-- testing load_csv operator to return table of vectors
-- in the same order of columns which is in the csv file
tests.t1 = function()
  
  local M = {
    { name = "empid", qtype = "I4" },
    { name = "yoj", qtype = "I2"}
  }

  local col = Q.load_csv(script_dir .. "multi_col_data_file.csv", M)

  local opt_args = {
                      opfile = "",
                      print_order = { "empid", "yoj" }
                    }
  local print_str = Q.print_csv(col, opt_args)
  
  local expected_str = "1001,2015\n1002,2011\n1003,2013\n1004,2017\n"
  assert(print_str == expected_str, "Mismatch in columns order")
  
  print("Successfully completed test t1")
end

return tests