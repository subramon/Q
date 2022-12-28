require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local lgutils = require 'liblgutils'
local mysplit = require 'Q/UTILS/lua/mysplit'
local tests = {}
tests.t1 = function()
  print("data_dir  = " .. lgutils.data_dir())
  print("meta_dir  = " .. lgutils.meta_dir())
  print("tbsp_name = " .. lgutils.tbsp_name())
  print("Test 1 of test_import completed")
end
tests.t2 = function()
  local new_meta_dir = "/home/subramon/local/Q/TEST_IMPORT/meta/"
  local new_data_dir = "/home/subramon/local/Q/TEST_IMPORT/data/"
  local tbsp = lgutils.import_tbsp(new_meta_dir, new_data_dir)
  assert(type(tbsp) == "number")
  assert(tbsp == 1)

  local oldpath = os.getenv("LUA_PATH")
  local T = mysplit(oldpath, ";")
  local newpath = new_meta_dir .. "/?.lua;" .. table.concat(T, ";") .. ";;"
  package.path = newpath
  --[[
  print(oldpath)
  print(newpath)
  local foo = require 'foo'
  assert(type(foo) == "function")
  assert(foo(2) == 4)
  -- contents of foo.lua shown below
print("Hello World")
local function foo(x)
  return x * x
end
return foo
  --]]
  -- g_tbsp = tbsp
  require 'q_meta'



  print("Test 2 of test_import completed")
end

-- WORKS tests.t1()
tests.t2()
