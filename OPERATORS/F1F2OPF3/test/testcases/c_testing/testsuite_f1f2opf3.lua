local qconsts = require 'Q/UTILS/lua/q_consts'
local plpath = require 'pl.path'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/OPERATORS/F1F2OPF3/test/testcases/c_testing"

-- list of qtypes to be operated on
local all_qtype = { "I1", "I2", "I4", "I8", "F4", "F8" }
local concat_in_qtypes = { "I1", "I2", "I4" }
local concat_out_qtypes = { "I2", "I4", "I8" }
-- data for each operator will be placed in test_<operator>.lua file
-- e.g. data for add operation is placed in test_vvadd.lua
local operators = { "vvadd", "vveq", "vvsub", "vvmul", "vvdiv", 
                    "vvgeq", "vvgt", "vvleq", "vvlt", "vvneq",
                    "vvrem"
                  } 

-- assert function, to compare the expected and actual output 
local assert_valid = function(expected, precision)
  return function (ret)
    for k,v in ipairs(ret) do
      -- print ( ret[k], expected[k])
      local final_result = tonumber(ret[k])
      local mult = 10^(precision or 0)
      local value = math.floor( final_result * mult + 0.5 ) / mult
      -- print ( ret[k], value, expected[k], precision)
      if value ~= expected[k] then 
        local failure_reason = "Actual value is " .. value .. " and expected is " .. expected[k]
        return false, failure_reason
      end
    end
    return true
  end
end
              
local create_tests = function() 
  local tests = {}  
  for i in pairs(operators) do -- traverse every operation
    local M = dofile(script_dir .."/input_" .. operators[i] .. ".lua")
    for m, n in pairs(M.data) do
      local q_type
      if n.qtype then q_type = n.qtype else q_type = all_qtype end
      for j in ipairs(q_type) do -- traverse every qtype
        for k in ipairs(q_type) do -- traverse every qtype
          local input_type1 = q_type[j]
          local input_type2 = q_type[k]
          local test_name = operators[i] .. "_" .. input_type1 .. "_" .. input_type2
          local expectedOut = n.z
          table.insert(tests, {
            input = {operators[i], input_type1, input_type2, n.a, n.b, M.output_qtype},
            check = assert_valid(expectedOut, n.precision),
            --fail = fail_str,
            name = test_name
          })                      
        end
      end
    end
  end
  
  local M = dofile(script_dir .."/input_concat.lua")
  for m, n in pairs(M.data) do
    local q_type
    if n.qtype then q_type = n.qtype end
    --for i in ipairs(q_type) do -- traverse every qtype
      --for j in ipairs(q_type) do -- traverse every qtype
        for k in ipairs(concat_out_qtypes) do -- traverse every qtype
          local input_type1 = q_type[1]
          local input_type2 = q_type[2]
          local output_type = concat_out_qtypes[k]
            
          local sz1 = assert(qconsts.qtypes[input_type1].width)
          local sz2 = assert(qconsts.qtypes[input_type2].width)
          local sz3 = assert(qconsts.qtypes[output_type].width)
          if sz3 > sz1 and sz3 > sz2 then
            --print(concat_in_qtypes[i], concat_in_qtypes[j], concat_out_qtypes[k])
            local test_name = "concat_" .. input_type1 .. "_" .. input_type2 .. "_" .. output_type
            --print(test_name)
            local expectedOut = n.z
            table.insert(tests, {
              input = {"concat", input_type1, input_type2, n.a, n.b, M.output_qtype },
              check = assert_valid(expectedOut, n.precision),
              --fail = fail_str,
              name = test_name
            })
          end
        end
      --end
    --end
  end
  
  return tests
end

local suite = {}
suite.tests = create_tests()
--require 'pl'
--pretty.dump(suite.tests)
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
