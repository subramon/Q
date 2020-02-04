-- FUNCTIONAL
require 'Q/UTILS/lua/strict'

local log = require 'Q/UTILS/lua/log'
local plpath = require 'pl.path'
local dir = require 'pl.dir'
local fns = require 'Q/UTILS/lua/utils'
local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/LOAD_CSV/test"

local tests = {}

tests.t1 = function ()
  local metadata_file_path = script_dir .."/meta.lua" 
  local csv_file_path = script_dir .."/test.csv"

  assert(plpath.isfile(metadata_file_path), "ERROR: Please check metadata_file_path")
  assert(plpath.isfile(csv_file_path), "ERROR: Please check csv_file_path")
   
  local M = dofile(metadata_file_path)
  fns["preprocess_bool_values"](M, "has_nulls", "is_dict", "add")

  -- set default values for globals
  --_G["Q_DATA_DIR"] = "./out/"     
  --_G["Q_META_DATA_DIR"] = "./metadata/"
  --dir.makepath(_G["Q_DATA_DIR"])
  --dir.makepath(_G["Q_META_DATA_DIR"])

  -- call load function to load the data
  local status, ret = pcall(load_csv, csv_file_path, M, { use_accelerator = false } )
  assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ") 

end

return tests
