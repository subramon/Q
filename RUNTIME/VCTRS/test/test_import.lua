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
  -- create a vector x which will get over-written by import
  x = Q.const({ val = 2, qtype = "F4", len = 3 }):eval()
  assert(x:num_elements() == 3)
  assert(x:qtype() == "F4")
  local new_meta_dir = "./TEST_IMPORT/meta/"
  local new_data_dir = "./TEST_IMPORT/data/"
  Q.import(new_meta_dir, new_data_dir)

  assert(type(x) == "lVector")
  local max_num_in_chunk = get_max_num_in_chunk()
  local len = 2 * max_num_in_chunk + 3 
  assert(x:num_elements() == len)
  assert(x:qtype() == "I4")
  local n1, n2 = Q.min(x):eval()
  local m1, m2 = Q.max(x):eval()
  assert(n1 == m1)
  assert(lgutils.mem_used() == 0)
  print("dsk used = ", lgutils.dsk_used())
  -- when you import a tablespace, that should NOT count
  -- against your disk usage
  assert(lgutils.dsk_used() == 0) 



  print("Test 2 of test_import completed")
end

tests.t1()
tests.t2()
