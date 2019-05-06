-- FUNCTIONAL
local utils = require 'Q/UTILS/lua/utils'
local testcase_results = require 'Q/UTILS/lua/testcase_results'
require 'Q/UTILS/lua/strict'

local plstring = require 'pl.stringx'
local plpath = require 'pl.path'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/UTILS/test"

local T = dofile(script_dir .."/map_utils.lua")

local tests = {}

local increment_failed_load = function (index, v, str)
  print("testcase name :"..v.name)
  
  print("reason for failure ::"..str)
end

--[[
function print_results()  
  local str
  
  str = "-----------Preprocess bool values testcases results---------------\n"
  str = str.."No of successfull testcases "..no_of_success.."\n"
  str = str.."No of failure testcases     "..no_of_failure.."\n"
  str = str.."---------------------------------------------------------------\n"
  if #failed_testcases > 0 then
    str = str.."Testcases failed are     \n"
    for k,v in ipairs(failed_testcases) do
      str = str..v.."\n"
    end
    str = str.."Run bash test_dictionary.sh <testcase_number> for details\n\n"
    str = str.."-------------------------------------------------------------\n"
  end 
  print(str)
  local file = assert(io.open("nightly_build_dictionary.txt", "w"), "Nighty build file open error")
  assert(io.output(file), "Nightly build file write error")
  assert(io.write(str), "Nightly build file write error")
  assert(io.close(file), "Nighty build file close error")
  
end
]]

-- this function handle the testcase where
-- error messages are expected output 
local handle_category1 = function (index, status, ret, metadata)
    if status then
      increment_failed_load(index, metadata, "testcase failed : in category 1 : Return status is expected to be false")
      return false
    end
    -- ret is of format <filepath>:<line_number>:<error_msg>
    -- get the actual error message from the ret
    local a, b, err = plstring.splitv(ret,':')
    -- trimming whitespace
    err = plstring.strip(err) 
    
    local expected = metadata.output_regex
    -- trimming whitespace
    expected = plstring.strip(expected)
    local count = plstring.count(err, expected )
  
    if count > 0 then
      return true
    else
      increment_failed_load(index, metadata, "testcase failed : in category 1 : Error message not matched with output_regex")
      print("actual output:" .. err)
      print("expected output:" .. expected)
      return false
    end
end

-- this function checks whether after passing valid metadata
-- the return type of preprocess bool is true
-- and whether it converts string of boolean values to boolean type
local handle_category2 = function (index, status, ret, metadata)
  -- metadata.metadata[1].add="true"
  if status ~= true then
    increment_failed_load(index, metadata, "testcase failed : in category 2 : Return status is expected to be true")
    return false
  end
  if (type(metadata.metadata[1].is_dict) ~= "boolean") then 
    increment_failed_load(index, metadata, "testcase failed : in category 2 : string of boolean value not converted to boolean type")
    return false
  end
  
  return true
end


local handle_function = {}
-- error code testcase
handle_function["category1"] = handle_category1
-- positive testcase
handle_function["category2"] = handle_category2

for i, v in ipairs(T) do
  -- testcase number which is entered in map file is an index into test_load table 
  -- which acts as an identifier for the test cases in this test suite.
  assert(v.testcase_number,"Specify testcase_no in map file for '" .. v.name .. "' testcase")
  tests[v.testcase_number] = function()
    print("Running testcase " .. v.testcase_number ..": ".. v.name)
    local M = v.metadata
    
    local status, ret = pcall(utils["preprocess_bool_values"], M, "is_dict", "add", "has_nulls")
    --local status, ret = utils["preprocess_bool_values"](M, "is_dict", "add", "has_nulls")
    local key = "handle_"..v.category
    local result = false
    if handle_function[v.category] then
      result = handle_function[v.category](i,status, ret, v)
      -- call to preamble
      testcase_results(v, "Preprocess Boolean values", "Unit Test", result, "")
      assert(result,"Handle category failed")
    else
      increment_failed_load(i, v, "Handle function for "..v.category.." is not defined in handle_category.lua")
      assert(handle_function[v.category],"Handle function for "..v.category.." is not defined in handle_category.lua")
    end
     
  end
end

return tests
