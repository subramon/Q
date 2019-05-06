-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local log = require 'Q/UTILS/lua/log'
local plpath = require 'pl.path'
local dir = require 'pl.dir'
local fns = require 'Q/UTILS/lua/utils'
local q_core = require 'Q/UTILS/lua/q_core'
local load_csv = require 'Q/OPERATORS/DATA_LOAD/lua/load_csv_dataload'
--assert( #arg == 2 , "Arguments are <metadata_file_path> <csv_file_path>")
local metadata_file_path = arg[1]
local csv_file_path = arg[2]

if metadata_file_path == nil and csv_file_path == nil then
  local script_dir = plpath.dirname(plpath.abspath(arg[0]))
  metadata_file_path = script_dir .."/meta.lua"
  csv_file_path = script_dir .."/test.csv"
end

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
local status, ret = pcall(load_csv, csv_file_path, M )
assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ") 

log.info("All is well")

require('Q/UTILS/lua/cleanup')()
os.exit()

