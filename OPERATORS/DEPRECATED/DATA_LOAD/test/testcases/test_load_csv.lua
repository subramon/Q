-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local load_csv = require 'Q/OPERATORS/DATA_LOAD/lua/load_csv_dataload'
local fns = require 'Q/OPERATORS/DATA_LOAD/test/testcases/handle_category'
local utils = require 'Q/UTILS/lua/utils'
local dir = require 'pl.dir'
local plpath = require 'pl.path'

local script_dir = plpath.dirname(plpath.abspath(arg[0]))
local test_input_dir = script_dir .."/test_data/"
local test_metadata_dir = script_dir .."/test_metadata/"

-- loop through testcases
-- these testcases output error messages
local T = dofile(script_dir .."/map_metadata_data.lua")
for i, v in ipairs(T) do
  if arg[1] and i ~= tonumber(arg[1]) then 
    goto skip 
  end
  
  _G["Q_DICTIONARIES"] = {}
  --_G["Q_DATA_DIR"] = "./test_data/out/"
  --_G["Q_META_DATA_DIR"] = "./test_data/metadata/"
  print("--------------------------------")
  local M = dofile(test_metadata_dir..v.meta)
  local D = v.data
  local result
  -- if category6 then set environment in handle_input_category6 function
  if v.category == "category6" then
    local key = "handle_input_"..v.category
    if fns[key] then
      fns[key](v.input_regex)
    else
      fns["increment_failed_load"](i, v, "Handle input function for "..v.category.." is not defined in handle_category.lua")
      goto skip
    end
  end
  
  local status, ret = pcall(load_csv,test_input_dir..D,  M)
  --local status, ret = load_csv(test_input_dir..D,  M)
  local key = "handle_"..v.category
  if fns[key] then
    result = fns[key](i, status, ret, v)
    -- print("see", result)
  else
    fns["increment_failed_load"](i, v, "Handle input function for "..v.category.." is not defined in handle_category.lua")
    result = false
  end
  utils["testcase_results"](v, "Data_load", "Unit Test", result, "")
  ::skip::
end

fns["print_result"]()
require('Q/UTILS/lua/cleanup')()
os.exit()

-- _G["Q_DATA_DIR"] = "./test_data/out/"
-- _G["Q_META_DATA_DIR"] = "./test_data/metadata/"
-- common cleanup (TEAR DOWN) for all testcases
-- clear the output directory 
--dir.rmtree(_G["Q_DATA_DIR"])
--dir.rmtree(_G["Q_META_DATA_DIR"])
