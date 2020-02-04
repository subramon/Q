-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local log = require 'Q/UTILS/lua/log'
local plpath = require 'pl.path'
local dir = require 'pl.dir'
local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/LOAD_CSV/test"

local tests = {}

-- testing load_csv to return value of 'meaning' field 
-- if it is set for any column in metadata
tests.t1 = function ()
  local metadata_file_path = script_dir .."/meta_meaning.lua" 
  local csv_file_path = script_dir .."/input_meaning.csv"

  assert(plpath.isfile(metadata_file_path), "ERROR: Please check metadata_file_path")
  assert(plpath.isfile(csv_file_path), "ERROR: Please check csv_file_path")
   
  local M = dofile(metadata_file_path)

  local col_names = { "pgvw_id", "sv_id", "sess_id", "time", "test_id", "variant_id", "dummy" }
  local col_meaning = { "page view id", "site visitor id", "session id", 
                        "time in msec since epoch", "test id", "variant id", nil }

  -- call load function to load the data
  local status, ret = pcall(load_csv, csv_file_path, M, {use_accelerator = false})
  assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ")
  -- validating the meaning field values
  for i = 1, #col_names do
    local md = ret[col_names[i]]:meta().aux["meaning"]
    assert(md == col_meaning[i])
  end
  print("Test t1 succeeded")
end

-- negative test: meaning field is not of type string
-- load_csv is expected to fail
tests.t2 = function ()
   
  local csv_file_path = script_dir .."/test.csv"
  assert(plpath.isfile(csv_file_path), "ERROR: Please check csv_file_path")
   
  local M = {
    { name = "empid", has_nulls = true, qtype = "I4", meaning = 5 }, 
    { name = "yoj", has_nulls = false, qtype ="I2", meaning = {} }
  }
  -- call load function to load the data
  local status, ret = pcall(load_csv, csv_file_path, M, {use_accelerator = false})
  assert( status == false )
  print("Test t2 succeeded")
end

return tests
