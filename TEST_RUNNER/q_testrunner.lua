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

Run luajit q_testrunner.lua to see its usage.
]]

package.path  = "/?.lua;" .. package.path -- TODO P4 What is this for?
local cutils   = require 'libcutils'

local qc       = require 'Q/UTILS/lua/q_core'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local plpretty = require "pl.pretty"
local plpath   = require "pl.path"

local q_root = qconsts.Q_ROOT
local recursive_lister = require 'Q/TEST_RUNNER/recursive_lister'
assert(cutils.isdir(q_root))
require('Q/UTILS/lua/cleanup')() -- cleanup data files if any

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

local function run_tests(suite_name)
  -- progress indicator 
  calls = calls + 1
  if calls == 20 then print("") calls = 0 end -- force eoln
  io.write(".")
  --==================
  local setup_path = string.format("export Q_ROOT='%s';\n", q_root)
  local base_str = [[
  export LUA_PATH="/?.lua;$LUA_PATH";
  L -e "require '%s'[%s]();collectgarbage();os.exit(0)" >/dev/null 2>&1]]
  base_str = setup_path .. base_str
  --===========================================
  -- Given a suite_name = foo.lua, if you do x  = require 'foo'
  -- then x should be a table of functions
  local suite_name_mod, subs = suite_name:gsub("%.lua$", "")
  assert(subs == 1, suite_name .. " should end with .lua")
  local status, tests = pcall(require, suite_name_mod)
  if not status then
    return {}, { msg = "Failed to load suite\n" .. tostring(suite_name) }
  end
  assert(type(tests) == "table")
  for _, t in pairs(tests) do assert(type(t) == "function") end 
  --===========================================
  local pass = {}
  local fail = {}
  for k, v in pairs(tests) do
    local base_cmd
    if ( type(k) == "number" ) then 
      base_cmd = 'luajit -e "t = require \'%s\'; t[%d](); os.exit(0)"'
    else
      base_cmd = 'luajit -e "t = require \'%s\'; t.%s(); os.exit(0)"'
    end
    local cmd = string.format(base_cmd, suite_name_mod, k)
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
local t_results = {}
local files = {}
if ( plpath.isfile(path) ) then
  files[#files+1] = path
else
  recursive_lister(files, path)
end
--- Now we have a list of files that need to be executed
for _,f in pairs(files) do
  t_results[f] = {}
  t_results[f].pass, t_results[f].fail = run_tests(f)
end
print(plpretty.write(t_results))

summary(t_results)
