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
  
  local orig_n = 3
  x = Q.const({ val = 2, qtype = "F4", len = orig_n })
  x:set_name("original_x")
  x:eval()
  assert(x:num_elements() == 3)
  assert(x:qtype() == "F4")
  bak_x = x
 
  local new_meta_dir = "./TEST_IMPORT/meta/"
  local new_data_dir = "./TEST_IMPORT/data/"
  Q.import("some tbsp name", new_meta_dir, new_data_dir)
  x:set_name("imported_x")
  assert(bak_x:num_elements() == orig_n)
  bak_x:delete()
  assert(lgutils.mem_used() == 0)
  assert(lgutils.tbsp_name(1) == "some tbsp name")



  assert(type(x) == "lVector")
  local max_num_in_chunk = get_max_num_in_chunk()
  local len = 2 * max_num_in_chunk + 3 
  assert(x:num_elements() == len)
  assert(x:qtype() == "I4")
  local rmin  = Q.min(x)
  local n1, n2 = rmin:eval()
  rmin:delete()

  local rmax  = Q.max(x)
  local m1, m2 = rmax:eval()
  rmax:delete()

  assert(n1 == m1)
  assert(n2 == m2)

  x:delete()
  collectgarbage()
  assert(lgutils.mem_used() == 0)
  -- when you import a tablespace, that should NOT count
  -- against your disk usage
  assert(lgutils.dsk_used() == 0) 



  print("Test 2 of test_import completed")
end
-- re-import several times 
tests.t3 = function()
  local niters = 4 -- do not exceed Q_MAX_NUM_TABLESPACES-1
  local new_meta_dir = "./TEST_IMPORT/meta/"
  local new_data_dir = "./TEST_IMPORT/data/"
  local initial_tbsp  = 0
  local tbsp_name = "some tbsp name" .. tostring(i)
  for i = 1, niters do 
    -- create a vector x which will get over-written by import
    x = Q.const({ val = 2, qtype = "F4", len = 3 }):eval()
    x:set_name("original_x")
    assert(x:num_elements() == 3)
    assert(x:qtype() == "F4")
    bak_x = x
    assert(x:tbsp() == 0)
   
    local tbsp_name = "some tbsp name" .. tostring(i)
    Q.import(tbsp_name, new_meta_dir, new_data_dir)
    x:set_name("imported_x")
    if ( i == 1 ) then 
      initial_tbsp = x:tbsp()
    else
      initial_tbsp = initial_tbsp + 1
      assert(initial_tbsp == x:tbsp())
    end
    bak_x:delete()
  
    assert(type(x) == "lVector")
    assert(x:qtype() == "I4")-- see make_data.lua
    assert(x:num_elements() == (2*64)+3) -- see make_data.lua
    x:delete()
    print("Iter = " .. i)
  end
  collectgarbage()
  assert(lgutils.mem_used() == 0)
  assert(lgutils.dsk_used() == 0) 
end

tests.t1() 
tests.t2()
tests.t3()
