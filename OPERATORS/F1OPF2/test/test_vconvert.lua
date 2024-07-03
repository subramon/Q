require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local lgutils = require 'liblgutils'
local cVector = require 'libvctr'


local tests = {}
tests.t1 = function()
  local pre_mem = lgutils.mem_used()
  for _, in_qtype in ipairs({"I2", "I4", "I8", "F4", "F8", }) do 
    local start = -1 * 32768
    local len = 65535
    local x = Q.seq({by = 1, qtype = in_qtype, start = start, len = len})
    for _, out_qtype in ipairs({"I2", "I4", "I8", "F4", "F8", }) do 
      local y = Q.vconvert(x, out_qtype)
      assert(y:qtype() == out_qtype)
      local z = Q.vconvert(y, in_qtype)
      assert(z:qtype() == in_qtype)
      local w = Q.vveq(x, z)
      local r = Q.sum(w)
      local n1, n2 = r:eval()
      assert(n1:to_num() == n2:to_num())
      y:delete()
      z:delete()
      w:delete()
      r:delete()
    end
    x:delete()
  end
  local post_mem = lgutils.mem_used()
  assert(pre_mem == post_mem)
  print("Test t1 succeeded")
end
tests.t_F2 = function()
  local pre_mem = lgutils.mem_used()
  local len = 65535
  local start = 0
  local x4 = Q.seq({start = 0, by = 1, qtype = "F4", len = len})
  x4:eval()
  local x2 = Q.vconvert(x4, "F2")
  local y4 = Q.vconvert(x2, "F4")
  y4:eval()
  Q.print_csv({x4, x2, y4}, { opfile = "_x.csv"})
  cVector.check_all()
  x4:delete()
  x2:delete()
  y4:delete()
  local post_mem = lgutils.mem_used()
  assert(pre_mem == post_mem)
  print("Test t1 succeeded")
end
tests.t4 = function()
  collectgarbage("stop")
  local pre_mem = lgutils.mem_used()
  local x = Q.mk_col({1,2,3,4}, "I4",
        { name = "my test name"}, {true, false, true, false})

  local y = Q.vconvert(x, "UI4"):set_name("y")

  assert(y:has_nulls())
  --============================
  local v = Q.vveq(x:get_nulls(), y:get_nulls())
  local r = Q.sum(v)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  v:delete(); r:delete()
  --============================
  local nn_y = y:get_nulls()
  y:drop_nulls()
  nn_y:delete()
  
  local chk_y = Q.mk_col({1,0,3,0}, "I4")
  local v = Q.vveq(y, chk_y)
  local r = Q.sum(v)
  local n1, n2 = r:eval()
  chk_y:delete()
  -- Q.print_csv({x,y})
  assert(n1 == n2)
  v:delete(); r:delete()
 
  y:delete(); 

  --=== test for F2 
  local a, b, c = x:get_chunk(0)
  assert(type(b) == "CMEM")
  assert(type(c) == "CMEM")
  x:unget_chunk(0)

  local z = Q.vconvert(x, "F4"):set_name("z"):eval()
  assert(z:has_nulls())
  local a, b, c = z:get_chunk(0)
  assert(type(b) == "CMEM")
  assert(type(c) == "CMEM")
  z:unget_chunk(0)
  

  local w = Q.vconvert(z, "F2"):set_name("w"):eval()
  assert(w:num_elements() == z:num_elements())
  assert(w:has_nulls())

  local u = Q.vconvert(w, "F4"):set_name("u"):eval()
  assert(u:num_elements() == z:num_elements())
  assert(u:has_nulls())

  local nn_z = z:get_nulls(); z:drop_nulls(); nn_z:delete()
  local nn_u = u:get_nulls(); u:drop_nulls(); nn_u:delete()

  local v = Q.vveq(z, u)
  local r = Q.sum(v)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  z:delete()
  w:delete()
  u:delete()
  v:delete()
  r:delete()
  
  x:delete()
  local post_mem = lgutils.mem_used()
  print(pre_mem, post_mem)
  cVector.hogs("mem")
  assert(pre_mem == post_mem)
  collectgarbage("restart")
  print("Test t4 succeeded")
end
-- tests.t1()
-- tests.t_F2()
-- tests.t3()
tests.t4()
-- return tests
