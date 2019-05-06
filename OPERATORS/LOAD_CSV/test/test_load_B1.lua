-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local log = require 'Q/UTILS/lua/log'
local plfile = require 'pl.file'
local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'
local diff = require 'Q/UTILS/lua/diff'
local gen = require 'Q/RUNTIME/test/generate_csv'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/LOAD_CSV/test"

local tests = {}

tests.t1 = function ()
  local metadata_file_path = script_dir .."/meta_B1.lua"
  -- no of rows in csv file are 65536 (i.e. equal to chunk_size)
  -- which are of pattern 010101..'s
  gen.generate_csv(script_dir .. "/input_file_B1.csv", "B1", 65540)
  local csv_file_path = script_dir .."/input_file_B1.csv"
   
  local M = dofile(metadata_file_path)

  -- call load function to load the data
  local status, ret = pcall(load_csv, csv_file_path, M )
  assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ")
  assert(ret['empid']:num_elements()==65540, "Incorrect number of elements in vector")
  local opt_args = {opfile = script_dir .. "/output_file_B1.csv"}
  Q.print_csv(ret['empid'], opt_args)

  local diff_status = diff(script_dir .. "/input_file_B1.csv", script_dir .. "/output_file_B1.csv")
  assert(diff_status, "Input and Output csv file not matched")
  log.info("All is well")
  
  plfile.delete(script_dir .. "/input_file_B1.csv")
  plfile.delete(script_dir .. "/output_file_B1.csv") 
end

return tests
