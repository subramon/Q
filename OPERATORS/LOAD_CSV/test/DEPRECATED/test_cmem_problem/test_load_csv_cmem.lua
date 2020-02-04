local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local fns = require 'Q/OPERATORS/LOAD_CSV/test/performance_testing/gen_csv_metadata_file'
local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/LOAD_CSV/test/test_cmem_problem/"

local tests = {}

local date = os.date("%d.%m.%Y")

tests[1] = function ()
  local csv_file_path = script_dir .. "csv_1mr_256c.csv"
  print("Loading file", csv_file_path)
  local M = dofile(script_dir .. "meta_info_1mr_256c.lua")
  -- generate metadata table which is to be passed to load csv
  local metadata_table = fns["generate_metadata"](M)
  
  local ret = load_csv(csv_file_path, metadata_table, { use_accelerator = false })
  local result
  if type(ret) == "table" then result = true else result = false end
  
  print("Done, test completed")
end

return tests
