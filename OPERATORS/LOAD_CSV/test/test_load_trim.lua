-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local fns = require 'Q/UTILS/lua/utils'
local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/LOAD_CSV/test"

local tests = {}

tests.t1 = function ()
  local metadata_file_path = script_dir .."/meta.lua" 
  local csv_file_path = script_dir .."/test_with_spaces.csv"

  local M = dofile(metadata_file_path)
  fns["preprocess_bool_values"](M, "has_nulls", "is_dict", "add")

  -- call load function to load the data
  local status, ret = pcall(load_csv, csv_file_path, M, { use_accelerator = false })
  assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ")

  Q.print_csv(ret['empid'])

  print("All is well")
end

return tests
