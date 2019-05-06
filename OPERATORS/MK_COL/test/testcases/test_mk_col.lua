-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local plpath = require 'pl.path'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local fns = require 'Q/OPERATORS/MK_COL/test/testcases/handle_category'
local testcase_results = require 'Q/UTILS/lua/testcase_results'
local qconsts = require 'Q/UTILS/lua/q_consts'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/MK_COL/test/testcases" 
local T = dofile(script_dir .."/map_mkcol.lua")

local test_mkcol = {}

-- this function is for generating large length input table required for mk_col
-- generally for testcases with num_elements more than chunk_size
local generate_input_table = function(qtype, no_of_rows, gen_type ) 
  local input_table = {}
  for i = 1, no_of_rows do
      local value
      
      if qtype == "B1" then
        if i % 2 == 0 then value = 0 else value = 1 end  
      else
        if gen_type == "random" then
          value = i*15 % qconsts.qtypes[qtype].max
        elseif(gen_type == "iter")then 
          value = i * 10
        end
      end
      --print(value)
      table.insert(input_table, value)
  end
  return input_table
end


for i, v in ipairs(T) do
  assert(v.testcase_no,"Specify testcase_no in map file for '" .. v.name .. "' testcase")
  
  -- testcase number which is entered in map file is an index into test_load table 
  -- which acts as an identifier for the test cases in this test suite.
  test_mkcol[v.testcase_no] = function()
    print("Running testcase " .. v.testcase_no .. ": " .. v.name)
    
    local input
    -- generating input(which is large in length) table for mk_col
    if v.category == "category2_1" then
      input = generate_input_table(v.qtype, v.num_elements, "random")
      -- now changing category2_1 to category2
      v.category = "category2"
      v.input = input
    else
      input = v.input
    end
    
    local qtype = v.qtype
    local result
    
    -- category1 are negative testcases ( error messages )
    if v.category == "category1" then
      print("START: Deliberate error attempt")
    end
    
    local status, ret = pcall(mk_col,input,qtype)
    if v.category == "category1" then
      print(ret)
      print("STOP : Deliberate error attempt")
    end
    
    if fns[v.category] then
      result = fns[v.category](i, v, status, ret)
      testcase_results(v, "Mk_col", "Unit Test", result, "")
      assert(result,"handle " .. v.category .. " assertions failed")
    else
      fns["increment_failed_mkcol"](i, v, "Handle input function for "..v.category.." is not defined in handle_category.lua")
      testcase_results(v, "Mk_col", "Unit Test", false, "")
      assert(fns[v.category], "handle category is not defined in handle_category_print.lua file") 
    end
  end
end

return test_mkcol
