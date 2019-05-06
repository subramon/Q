-- FUNCTIONAL

local Q = require 'Q'
local testcase_results = require 'Q/UTILS/lua/testcase_results'
require 'Q/UTILS/lua/strict'
local f1f2opf3 = require 'Q/OPERATORS/F1F2OPF3/test/testcases/lua_testing/f1f2opf3'
local testsuite_f1f2opf3 = require 'Q/OPERATORS/F1F2OPF3/test/testcases/lua_testing/testsuite_f1f2opf3'
 
local call_if_exists = function (f)
  if type(f) == 'function' then
    f()
  end
end
--[[ 
f1f1opf3: Lua function to be tested
tests_to_run: OPTIONAL;table-array of test-numbers specifying which tests are to be run. If unspecified, all tests are run
--]]

local tests_to_run = {} 

for i=1,#testsuite_f1f2opf3.tests do 
  table.insert(tests_to_run, i)
end
  
--[[
-- local failures = ""
local function myassert(cond, i, name, msg) 
  if not cond then
    failures = failures .. i
    if name then failures = failures .. ' - ' .. name .. '\n' end
    if msg then failures = failures .. "[" .. msg .. "],\n" end
  end
end
]]

local test_suite = {}
local status, res
local test
--call_if_exists(suite.setup)

for k,test_num in pairs(tests_to_run) do
  test_suite[test_num] = function()
    assert(testsuite_f1f2opf3.tests[test_num], "No test at index" .. test_num .. " in testsuite")
    test = testsuite_f1f2opf3.tests[test_num]
    print ("running test " .. test_num, test.name )
    --call_if_exists(test.setup)
    status, res = pcall(f1f2opf3, unpack(test.input))
    local result, reason
 
    if status then
      result, reason = test.check(res)
      -- preamble
      testcase_results(test, testsuite_f1f2opf3.test_for, testsuite_f1f2opf3.test_type, result, "")
      if reason ~= nil then
        assert(result,"test name: " .. test.name .. " :: Reason: " .. reason)
      end
      assert(result,"test name: " .. test.name)
      -- myassert (result, test_num, test.name)
    else      
      -- preamble
      testcase_results(test, testsuite_f1f2opf3.test_for, testsuite_f1f2opf3.test_type, status, "")
      if res ~= nil then
        assert(status,"test name: " .. test.name .. " :: Reason: " .. res)
      end
      assert(status,"test name: " .. test.name)
      -- myassert (result, test_num, test.name, res)
    end
    --call_if_exists(test.teardown)
  end
end
  --call_if_exists(suite.teardown)
return test_suite
