-- FUNCTIONAL
local Q = require 'Q'
local plpath = require 'pl.path'
local fns = require 'Q/UTILS/lua/utils'
local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local utils = require 'Q/UTILS/lua/utils'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/LOAD_CSV/test"

local tests = {}

-- checking of the Q.load_csv operator to create a new hash column('I8') 
-- for the respective SC column
-- load_csv should return 2 vectors (SC and hash column of it)
tests.t1 = function ()
  local metadata_file_path = script_dir .."/meta_hash.lua" 
  local csv_file_path = script_dir .."/test_hash.csv"

  assert(plpath.isfile(metadata_file_path), "ERROR: Please check metadata_file_path")
  assert(plpath.isfile(csv_file_path), "ERROR: Please check csv_file_path")
   
  local M = dofile(metadata_file_path)
  fns["preprocess_bool_values"](M, "has_nulls", "is_dict", "add")
  
  -- call load function to load the data
  local status, ret = pcall(load_csv, csv_file_path, M )
  assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ")
  assert(utils.table_length(ret) == #M+1)
  assert(ret['empid_I8'])
  assert(ret['empid_I8']:length()== ret['empid']:length())
  -- validating row 1 and 7, row 2 and 8
  -- should return same hash for the same SC value
  assert(c_to_txt(ret['empid_I8'], 1) == c_to_txt(ret['empid_I8'],7))
  assert(c_to_txt(ret['empid_I8'], 2) == c_to_txt(ret['empid_I8'],8))
  Q.print_csv(ret)
  print("Successfully completed test t1")
end

return tests
