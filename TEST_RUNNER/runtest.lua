--[[
For the purposes of this tool, below are axiomatic definitions:

"Test"/"Test case": A lua function that takes no arguments, and
returns nothing. It is typically expected that this function will test
some behavior using assert's.

"Pass": A test is considered to pass if it returns successfully
without any errors "Fail": A test is considered to fail if it raises
an error (typically due to a failed assert)

"Test suite": A .lua file that, when require'd, returns an table of
test cases. For each entry of the table, the key acts as the
identifier/name of a test case, the value is the test case itself.
Note that the table can also be an array, in which case the
index-into-array is the identifier for the test cases in that suite.

Run luajit runtest.lua to see its usage.
]]

package.path  = "/?.lua;" .. package.path -- TODO P4 What is this for?
local cutils   = require 'libcutils'

local qc       = require 'Q/UTILS/lua/qcore'
local cleanup  = require 'Q/UTILS/lua/cleanup'
local qconsts  = require 'Q/UTILS/lua/qconsts'
local qcfg     = require 'Q/UTILS/lua/qcfg'
local plpretty = require "pl.pretty"
local plpath   = require "pl.path"
cleanup()
local recursive_lister = require 'Q/TEST_RUNNER/recursive_lister'

local q_src_root = qcfg.q_src_root
assert(cutils.isdir(q_src_root))
local setup_path = string.format("export q_src_root='%s';\n", q_src_root)

local calls = 0

local function summary(t_results)
  local cnt = {
    suites = {pass = 0, fail = 0},
    tests = {pass = 0, fail = 0}
  }
  for _,t in pairs(t_results) do
    cnt.tests.pass = cnt.tests.pass + #t.pass
    cnt.tests.fail = cnt.tests.fail + #t.fail
    if #t.fail == 0 then
      cnt.suites.pass = cnt.suites.pass + 1
    else
      cnt.suites.fail = cnt.suites.fail + 1
    end
  end
  local summary = plpretty.write(cnt, "")

  if cnt.tests.fail == 0 then
    print ("SUCCESS " .. summary) else print ("FAILURE " .. summary)
  end
end

local function run_tests(suite_name, test_name)
  -- progress indicator 
  calls = calls + 1
  if calls == 20 then print("") calls = 0 end -- force eoln
  io.write(".")
  --==================
  -- Does this need to be part of base_str export LUA_PATH="/?.lua;$LUA_PATH";
  local base_str = [[
  luajit  -e "require '%s'[%s]();collectgarbage();os.exit(0)" >/dev/null 2>&1]]
  base_str = setup_path .. base_str
  --===========================================
  -- Given a suite_name = foo.lua, if you do x  = require 'foo'
  -- then x should be a table of functions
  local status, tests = pcall(require, suite_name)
  if not status then
    print(tests) -- this is the error message on failure
    return {}, { msg = "Failed to load suite\n" .. tostring(suite_name) }
  end
  assert(type(tests) == "table", 
    "Script [ " .. suite_name .. "] did not return table of functions")
  for _, t in pairs(tests) do 
    assert(type(t) == "function", 
      "Script [ " .. suite_name .. "] did not return tbl of fns")
  end 
  --===========================================
  local pass = {}
  local fail = {}
  if ( test_name ) then 
    local x_tests = {}
    for k, v in pairs(tests) do
      if ( k == test_name ) then
        x_tests[k] = v
      end
    end
    tests = x_tests
  end
  for k, v in pairs(tests) do
    local base_cmd
    if ( type(k) == "number" ) then 
      base_cmd = 'luajit -e "t = require \'%s\'; t[%d](); os.exit(0)"'
    else
      base_cmd = 'luajit -e "t = require \'%s\'; t.%s(); os.exit(0)"'
    end
    local cmd = string.format(base_cmd, suite_name, k)
    local status = os.execute(cmd)
    io.write(".")
    if status == 0 then
      table.insert(pass, k)
    else
      table.insert(fail, k)
    end
  end
  return pass, fail
end


local path      = assert(arg[1], "Error: provide file or directory")
-- test_name allows us to focus on just one test in a suite
local test_name 
if ( arg[2] ) then test_name = arg[2] end 
--====================================
local t_results = {}
local files = {}
if ( plpath.isfile(path) ) then
  -- we have provided a file, not a directory
  files[#files+1] = path
else
  -- we have provided a directory
  -- assemble a list of all files with name test_*.lua contained therein
  recursive_lister(files, path)
end
assert(#files > 0)
-- cannot specify a test name when more than one file being evaluated
if ( #files > 1 ) then test_name = nil end 
local xfiles = {}
for k, file in ipairs(files) do 
  -- modify files to start from "Q/..."
  local x = plpath.abspath(file)
  local y = string.gsub(x, q_src_root, "Q/")
  local z, subs = y:gsub("%.lua$", "")
  assert(subs == 1, "file_name should end with .lua. It is " .. file)
  xfiles[k] = z
end
files = xfiles 
-- for k, v in pairs(files) do print(k, v) end
--- Now we have a list of files that need to be executed
for _,f in pairs(files) do
  t_results[f] = {}
  t_results[f].pass, t_results[f].fail = run_tests(f, test_name)
end
print(plpretty.write(t_results))

summary(t_results)
