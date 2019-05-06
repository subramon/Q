-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local load_csv = require 'Q/OPERATORS/LOAD_CSV/lua/load_csv'
local fns = require 'Q/OPERATORS/LOAD_CSV/test/testcases/handle_category'
local testcase_results = require 'Q/UTILS/lua/testcase_results'
local plpath = require 'pl.path'
local gen_csv = require 'Q/RUNTIME/test/generate_csv'
local plfile = require 'pl.file'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/LOAD_CSV/test/testcases"

local test_input_dir = script_dir .."/data/"
local test_metadata_dir = script_dir .."/metadata/"

local T = dofile(script_dir .."/map_metadata_data.lua")

local test_load = {}

for i, v in ipairs(T) do
  assert(v.testcase_no,"Specify testcase_no in map file for '" .. v.name .. "' testcase")
  
  -- testcase number which is entered in map file is an index into test_load table 
  -- which acts as an identifier for the test cases in this test suite.
  test_load[v.testcase_no] = function()
    print("Running testcase " .. v.testcase_no ..": ".. v.name)
    local M = dofile(test_metadata_dir..v.meta)
    local D = v.data
    local opt_args = v.opt_args
    local result
    v.col_names = M
    
    if v.category == "category2_1" then
    gen_csv.generate_csv(test_input_dir .. D, M[1].qtype, v.num_elements, "random")
    end
    -- category1 are negative testcases ( error messages )
    if v.category == "category1" then
      print("START: Deliberate error attempt")
    end
    
    local status, ret = pcall(load_csv,test_input_dir..D,  M, opt_args)
    if v.category == "category1" then
      print(ret)
      print("STOP : Deliberate error attempt")
    end
    
    local key = "handle_"..v.category
    if fns[key] then
      result = fns[key](i, status, ret, v, M[1].qtype)
      -- preamble
      testcase_results(v, "Load_csv", "Unit Test", result, "")
      assert(result,"handle " .. v.category .. " assertions failed")
    else
      fns["increment_failed_load"](i, v, "Handle function for "..v.category.." is not defined in handle_category.lua")
      testcase_results(v, "Load_csv", "Unit Test", result, "")
      assert(fns[key], "handle category is not defined in handle_category_print.lua file") 
    end
    if v.category == "category2_1" then
      plfile.delete(test_input_dir .. D)
    end
  end
end

return test_load
