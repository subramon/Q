local qconsts = require 'Q/UTILS/lua/q_consts'
local ffi = require 'Q/UTILS/lua/q_ffi'
local plpath = require 'pl.path'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/F1F2OPF3/test/testcases/lua_testing"

-- list of qtypes to be operated on
local all_qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }

-- data for each operator will be placed in test_<operator>.lua file
-- e.g. data for add operation is placed in test_vvadd.lua

local operations = { "vvadd", "vvsub", "vvmul", "vvdiv", "vveq",
                     "vvneq", "vvgeq", "vvgt", "vvleq", "vvlt",
                     "vvrem", "vvxor",
                     -- commenting the following operators which are failing,
                     -- "vvand", "vvor", "vvandnot"
                     -- created a separate test file OPERATORS/F1F2OPF3/test/test_f1f2opf3_logical_op.lua
                     -- to test these operator  
                   } 

local assert_valid = function(expected, precision)
  return function (col)
    assert(type(expected) == "table", "Expected result type should be of type table")
    assert(type(col) == "lVector", "Result type should be of type column")
    assert(col:length() == #expected, "Expected table and result column length not same")
    
    for itr,value in ipairs(expected) do
      local c_data = c_to_txt(col, itr)
      local md = col:meta()
      local output_type = md.base.field_type
      local final_result
      if output_type == "B1" then
        if c_data == nil then final_result = 0  else  final_result = tonumber(c_data) end
      else
        final_result = c_data
      end
      -- rounding logic for float q_types
      if output_type == "F4" or output_type == "F8" then
        local mult = 10^(precision or 0)
        final_result = math.floor( final_result * mult + 0.5 ) / mult
      end
      if final_result ~= value then 
        local failure_reason = "Actual value is " .. final_result .. " and expected is " .. value
        return false, failure_reason
      end
    end
    return true
  end
end

local create_tests = function() 
  local tests = {}  
  for i in pairs(operations) do -- traverse every operation
    local M = dofile(script_dir .."/input_" .. operations[i] .. ".lua")
    for m, n in pairs(M.data) do
      local q_type
      if n.qtype then q_type = n.qtype else q_type = all_qtype end
      for j in ipairs(q_type) do -- traverse every qtype
        for k in ipairs(q_type) do -- traverse every qtype
          local input_type1 = q_type[j]
          local input_type2 = q_type[k]
          local test_name = operations[i] .. "_" .. input_type1 .. "_" .. input_type2
          local expectedOut = n.z
          table.insert(tests, {
            input = { operations[i], input_type1, input_type2, n.a, n.b },
            check = assert_valid(expectedOut, n.precision),
            name = test_name
          })                      
        end
      end
    end
  end
  
  -- Note: concat testcases will fail for now 
  -- as expander_f1f2opf3.lua needs to pass optargs as an argument 
  -- to concat_specialize.lua file
  local M = dofile(script_dir .."/input_concat.lua")
  for m, n in pairs(M.data) do
    local q_type
    if n.qtype then q_type = n.qtype end
    local input_type1 = q_type[1]
    local input_type2 = q_type[2]
    local test_name = "concat_" .. input_type1 .. "_" .. input_type2 
    local expectedOut = n.z
    table.insert(tests, {
      input = {"concat", input_type1, input_type2, n.a, n.b},
      check = assert_valid(expectedOut, n.precision),
      name = test_name
    })
  end
  return tests
end 

local suite = {}
suite.tests = create_tests()

-- Suite level setup/teardown can be specified
suite.setup = function() 
  -- print ("in setup!!")
end

suite.test_for = "F1F2OPF3"
suite.test_type = "Unit Test"
suite.teardown = function()
  -- print ("in teardown!!")
end

return suite
