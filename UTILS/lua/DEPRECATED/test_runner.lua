-- NO_OP
--[[
Expected to be run as a command line program; takes below arguments
    "funcUnderTest": Mandatory; is a module that returns the function to be tested. This is in accordance with the convention we're following for Q modules.
    "testSuite": Mandatory; this parameter, when "require"d, should return a "suite" as defined below
    "testsToRun": Optional; string representation of lua table-array e.g. {1,3} indicating which specific tests should be run from the suite. Note: if running from shell script, escape the braces e.g. \{1,3\}
--------
"suite": is a table with below structure
{
  "tests": {... array of "test" objects, see "test" definition below}
  "setup": <OPTIONAL; function to be called before the tests are executed>
  "teardown": <OPTIONAL; function to be called after the tests are executed>
}

"test": A test is table with below structure
{
  "input": {...array of parameters to test function ...}
  "fail": "<expected substring of error message in case of a failure test-case>"
  "check": <callback function that is called with the output of invoking test-function>
  "setup": <OPTIONAL; function to be called before this test is executed>
  "teardown": <OPTIONAL; function to be called after this test is executed>
}
"fail" and "check" are mutually exclusive, exactly one of them should be present in a test.

"fail" should be specified if and only if the invocation to funcUnderTest is expected to result in an error.
"check" should be a function that takes a single argument (actual result of invoking funcUnderTest) and does all validation checks. It should return a boolean - true if actual matches expected; false otherwise

This test_runner program runs all tests, and logs all failed test-cases with their number (index in tests array)
--]]

--print ("LUA PATH " .. package.path)
--print ("TERRA PATH" .. package.terrapath)

-- require 'Q/UTILS/lua/q_consts'
-- require 'terra_globals'
-- require 'Q/UTILS/lua/error_code'
local pretty = require 'pl.pretty'

print ("Function under test: " .. arg[1])
print ("Test suite: " .. arg[2])

local suite_runner = require 'Q/UTILS/lua/suite_runner'
local fn = require (arg[1])
local suite = require (arg[2])
local tests_to_run = arg[3]

if tests_to_run ~= nil then
  tests_to_run = assert(pretty.read(tests_to_run))
end

local failures = suite_runner(suite, fn, tests_to_run)
if (#failures > 0) then
  print ("Failed testcases are: \n" .. tostring(failures))
else
  print("Tests passed.")
end
os.exit() -- For LuaJIT
