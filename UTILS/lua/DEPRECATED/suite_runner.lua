local utils = require 'Q/UTILS/lua/utils'

local call_if_exists = function (f)
  if type(f) == 'function' then
    f()
  end
end

--[[ 
Refer comments in test_runner to understand the parameters of this function
suite: Suite as defined in test_runner
fn: Lua function to be tested
tests_to_run: OPTIONAL;table-array of test-numbers specifying which tests are to be run. If unspecified, all tests are run
--]]
return function (suite, fn, tests_to_run)
  local status, res
  local failures = ""
  if tests_to_run == nil then
    tests_to_run = {}
    for i=1,#suite.tests do 
      table.insert(tests_to_run, i)
    end
  end
  
  local function myassert(cond, i, name, msg) 
    if not cond then
      failures = failures .. i
      if name then failures = failures .. ' - ' .. name .. '\n' end
      if msg then failures = failures .. "[" .. msg .. "],\n" end
    end
  end
  
  local test
  call_if_exists(suite.setup)
  
  for k,test_num in pairs(tests_to_run) do
    print ("running test " .. test_num)
    test = suite.tests[test_num]
    call_if_exists(test.setup)
    status, res = pcall(fn, unpack(test.input))
    local result

    if test.fail then
      result = string.match(res, test.fail)
      myassert (status == false, test_num, test.name)
      myassert (result, test_num, test.name)
    else
      if status then
        result = test.check(res)
        myassert (result, test_num, test.name)
      else      
        result = status
        myassert (result, test_num, test.name, res)
      end
    end
    utils["testcase_results"](test, suite.test_for, suite.test_type, result, "")
    call_if_exists(test.teardown)
  end
  call_if_exists(suite.teardown)
  return failures
end
