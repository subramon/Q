-- FUNCTIONAL
local Q = require 'Q'
local plpath = require 'pl.path'
local fns = require 'Q/UTILS/lua/utils'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local utils = require 'Q/UTILS/lua/utils'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/HASH/test"

local tests = {}

-- checking of the Q.hash operator to accept vector as input(of type "SC") 
-- and return hash value vector as output(of type "I8") 
tests.t1 = function ()
  local metadata_file_path = script_dir .."/meta_hash.lua" 
  local csv_file_path = script_dir .."/test_hash.csv"

  assert(plpath.isfile(metadata_file_path), "ERROR: Please check metadata_file_path")
  assert(plpath.isfile(csv_file_path), "ERROR: Please check csv_file_path")
   
  local M = dofile(metadata_file_path)
  fns["preprocess_bool_values"](M, "has_nulls", "is_dict", "add")
  
  -- call to load function to create SC column
  local status, ret = pcall(Q.load_csv, csv_file_path, M )
  assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ")
  -- call to hash function which returns I8 column

  local I8_col = Q.hash(ret['empid']):eval()
  assert(I8_col)
  assert(I8_col:length()== ret['empid']:length())
  Q.print_csv(I8_col)
  -- validating row 1 and 7, row 2 and 8
  -- should return same hash for the same SC value
  assert(c_to_txt(I8_col, 1) == c_to_txt(I8_col,7))
  assert(c_to_txt(I8_col, 2) == c_to_txt(I8_col,8))
  print("Successfully completed test t1")
end

tests.t2 = function ()
  local vec = Q.mk_col({1, 2, 3, 4}, "I2")
  local out = Q.hash(vec)
  Q.print_csv(out)
end

-- TODO P1 Additional tests to write
-- Create 2 identical vectors. hash them using default seeds
-- Output vectors should be the same
--
-- Create 2 different vectors (no elements in common)
-- hash them using default seeds
-- Output vectors  should not have any elements in common
--
-- Create 2 identical vectors. hash them using custom seeds
-- but same in both cases
-- Output vectors should be the same

-- Create 2 identical vectors. hash them using different custom seeds
-- but same in both cases
-- Output vectors  should not have any elements in common
--
-- Repeat all above tests for vector lengths in
-- qconsts.chunk_size - 17
-- qconsts.chunk_size 
-- 2*qconsts.chunk_size + 33

-- Repeat all above tests for all possible qtypes 
--
-- Ideally, you have a doubly nested for loop to test all variations
return tests
