require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local lgutils = require 'liblgutils'
local mysplit = require 'Q/UTILS/lua/mysplit'
local get_max_num_in_chunk = require 'Q/UTILS/lua/get_max_num_in_chunk'
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
  assert(type(x) == "lVector")
  local max_num_in_chunk = get_max_num_in_chunk()
  local len = 2 * max_num_in_chunk + 3 
  assert(x:num_elements() == len)
  assert(x:qtype() == "I4")
  local n1, n2 = Q.min(x):eval()
  local m1, m2 = Q.max(x):eval()
  assert(n1 == m1)



  print("Test 2 of test_import completed")
end

-- WORKS tests.t1()
tests.t2()
