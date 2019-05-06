-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local Dictionary = require "Q/UTILS/lua/dictionary"
local plstring = require 'pl.stringx'
local plfile = require 'pl.path'
local testcase_results = require 'Q/UTILS/lua/testcase_results'
local plpath = require 'pl.path'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/UTILS/test"

local T = dofile(script_dir .."/map_dictionary.lua")
--_G["Q_DICTIONARIES"] = {}

local tests = {}

local increment_failed_load = function (index, v, str)
  print("testcase name :"..v.name)
  print("Meta file: "..v.meta)
  
  print("reason for failure ::"..str)
--[[  
  print("\n-----------------Meta Data File------------\n")
  os.execute("cat /home/pragati/Desktop/Q/UTILS/test/test_metadata/"..v.meta) 
  print("\n--------------------------------------------\n")
]]  
end

-- this function checks whether after passing valid metadata
-- the return type of Dictionary is Dictionary or not

local handle_category1 = function (index, ret, metadata)
  if type(ret) == "Dictionary" then
    return true
  else
    increment_failed_load(index, metadata, "testcase failed : in category 1 : Return type not Dictionary")
    return false
  end
end

-- this function handle the testcase where
-- error messages are expected output
-- if null or empty string is passed to add dictionary function 
-- it should give an error

local handle_category2 = function (index, ret, metadata)
    local status, add_err = pcall(ret.add,metadata.input)
    local a, b, err = plstring.splitv(add_err,':')
    err = plstring.strip(err) 
    
    local expected = metadata.output_regex
    local count = plstring.count(err, expected )
  
    if count > 0 then
      return true
    else
      increment_failed_load(index, metadata, "testcase failed : in category 2 : Error message not matched with output_regex")
      return false
    end
end

-- this function checks whether valid string entries are added in dictionary 
-- and checking if get_size gives a valid size of a dictionary

local handle_category3 = function (index, ret, metadata)
  
  for i=1, #metadata.input do
    ret:add(metadata.input[i])
  end

  local dict_size = ret:get_size()
  if dict_size == metadata.dict_size then
    return true
  else
    increment_failed_load(index, metadata, "testcase failed : in category 3 : Not added entries in dictionary properly")
    return false
  end
end

-- this function checks whether a correct index 
-- of a valid string is returned from a dictionary

local handle_category4 = function (index, ret, metadata)
  for i=1, #metadata.input do
    ret:add(metadata.input[i])
  end
  
  for i=1, #metadata.input do
    if ret:get_index_by_string(metadata.input[i]) ~= metadata.output_regex[i] then
      increment_failed_load(index, metadata, "testcase failed : in category 4 : Invalid index entry")
      return false
    end
  end
  
  return true
end

-- this function checks whether a correct string 
-- of a valid index is returned from a dictionary

local handle_category5 = function (index, ret, metadata)
  for i=1, #metadata.input do
    ret:add(metadata.input[i])
  end
  
  for i=1, #metadata.input do
    if ret:get_string_by_index(i) ~=  metadata.input[i] then
      increment_failed_load(index, metadata, "testcase failed : in category 4 : Invalid string entry")
      return false
    end
  end
  
  return true
end


--[[
function print_results()  
  local str
  
  str = "-----------Dictionary testcases results for LOAD_CSV---------------\n"
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
local handle_function = {}
-- to test whether return type is Dictionary
handle_function["category1"] = handle_category1
-- checking of invalid dict add to a dictionary
handle_function["category2"] = handle_category2
-- checking of valid dict add to a dictionary 
-- and checking valid get size of a dictionary
handle_function["category3"] = handle_category3
-- checking valid get index from a dictionary
handle_function["category4"] = handle_category4
-- checking valid get string from a dictionary
handle_function["category5"] = handle_category5

local function calling_dictionary(i ,m)
    local M = dofile(script_dir .."/metadata/"..m.meta)
    local result
    local ret = assert(Dictionary(M.dict))
    
    if handle_function[m.category] then
      result = handle_function[m.category](i,ret, m)
      -- call to preamble
      testcase_results(m, "Dictionary", "Unit Test", result, "")
      assert(result,"Handle category failed")
    else
      increment_failed_load(i, m, "Handle function for "..m.category.." is not defined in handle_category.lua")
      assert(handle_function[m.category],"Handle function for "..m.category.." is not defined in handle_category.lua")
    end 
end



for i, m in ipairs(T) do
  -- testcase number which is entered in map file is an index into test_load table 
  -- which acts as an identifier for the test cases in this test suite.
  assert(m.testcase_number,"Specify testcase_no in map file for '" .. m.name .. "' testcase")
  tests[m.testcase_number] = function()
    print("Running testcase " .. m.testcase_number ..": ".. m.name)
    -- for testcase 5 and 7 testcase 4 should be executed for the dictionary to in existence 
    if m.testcase_number == 5 or m.testcase_number == 7 then
      local no_of_tc = {}
      if m.testcase_number == 5 then no_of_tc = { 4, 5 } end
      if m.testcase_number == 7 then no_of_tc = { 4, 7 } end
      for j=1,#no_of_tc do
        i = no_of_tc[j]
        m = T[i]
        calling_dictionary(i, m)
      end
    else
      calling_dictionary(i, m)
    end
  end
end

return tests
