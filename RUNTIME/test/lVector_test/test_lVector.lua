local dir = require 'pl.dir'
local fns =  require 'Q/RUNTIME/test/lVector_test/assert_valid'
local genbin = require 'Q/RUNTIME/test/generate_bin'
local create_vector = require 'Q/RUNTIME/test/lVector_test/create_vector'
local testcase_results = require 'Q/UTILS/lua/testcase_results'
local qc = require 'Q/UTILS/lua/q_core'

local Q_SRC_ROOT = os.getenv("Q_SRC_ROOT")
local script_dir = Q_SRC_ROOT .. "/RUNTIME/test/lVector_test"
dir.makepath(script_dir .."/bin/")

local all_qtype = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8', 'SC', 'SV' }

-- for calling respective validating functions for each testcase
local assert_valid = function(res, map_value, qtype)
  -- calling the assert function based on type of vector
  local function_name = "assert_" .. map_value.assert_fns
  local status, fail_msg = pcall(fns[function_name], res, map_value.name .. qtype, map_value.num_elements, map_value.gen_method)
  if not status then 
    return status, fail_msg
  end
  if map_value.test_category == "error_testcase_1" then 
    print("STOP : Deliberate error attempt")
  end
  return status
end


local gather_test_meta_data = function(map_value, qtype)
  assert(map_value.num_elements, "Provide number of elements in map_file")
  assert(map_value.meta, "Provide metadata filename required for vector in map_file ")  
  local M = dofile(script_dir .."/meta_data/"..map_value.meta)
  if map_value.test_type == "materialized_vector" then
    local bin_file_name
    -- if "${q_type}" = positive testcase: they want input .bin file to be generated
    -- else negative testcase: dont want input .bin file to be generated
    if string.match( M.file_name,"${q_type}" ) then
      bin_file_name = script_dir.."/bin/in_" .. qtype .. ".bin"
      -- generating .bin files required for materialized vector
      qc.generate_bin(map_value.num_elements, qtype, bin_file_name, "seq" )
      -- for .bin file
      M.file_name = bin_file_name
      -- for .nn bin file
      if M.nn_file_name then
        M.nn_file_name = script_dir .. "/" .. M.nn_file_name
      end
    end
  end
  M.qtype = qtype
  M.num_elements = map_value.num_elements
  return M
end

local lVector_tests = {}
local T = dofile(script_dir .."/map_lVector.lua")

for i, map_value in ipairs(T) do
  local qtype
  if map_value.qtype then qtype = map_value.qtype else qtype = all_qtype end
  for j in pairs(qtype) do
    -- creating individual test-case as an entry in lVector_tests 
    lVector_tests[#lVector_tests + 1] = function()
      map_value.name = map_value.name .. "_" .. qtype[j]
      local M = gather_test_meta_data(map_value, qtype[j])
     
      -- print messages for negative testcases
      if map_value.test_category == "error_testcase_1" or map_value.test_category == "error_testcase_2" then 
        print("START: Deliberate error attempt")
      end
      
      local status, res = pcall(create_vector, M)
      if map_value.test_category == "error_testcase_2" then
        print("STOP : Deliberate error attempt")
      end
      local result, reason
      
      if status then
        result, reason = assert_valid(res, map_value, qtype[j])
        -- preamble
        testcase_results(map_value, "lVector", "Unit Test", result, "")
        if reason ~= nil then
          assert(result,"test name:" .. map_value.name .. ":: Reason: " .. reason)
        end
        assert(result,"test name:" .. map_value.name)
      else      
        -- preamble
        testcase_results(v, "lVector", "Unit Test", status, "")
        if res ~= nil then
          assert(status,"test name:" .. map_value.name .. ":: Reason: " .. res)
        end
        assert(status,"test name:" .. map_value.name)
      end
    end
  end
end

return lVector_tests
