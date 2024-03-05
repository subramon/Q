-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local lgutils = require 'liblgutils'

local yqtypes = { "I1", "I2", "I4", "I8", "F4", "F8", }
local xqtypes = { "BL",  } -- TODO Add "B1"
local opt_args = { opfile = "_x" }
local tests = {}
tests.t1 = function()
  collectgarbage("stop")
  local pre_mem = lgutils.mem_used() 
  for _, xqtype in ipairs(xqtypes) do 
    for _, yqtype in ipairs(yqtypes) do
      local x = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, xqtype):set_name("x")
      local y = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, yqtype):set_name("y")
      local z = Q.mk_col({-1, -2, -3, -4, -5, -6, -7}, yqtype):set_name("z")
      local exp_w = Q.mk_col({1, -2, 3, -4, 5, -6, 7}, yqtype):set_name("exp_w")
      local w = Q.ifxthenyelsez(x, y, z):set_name("w"):eval()
      -- Q.print_csv({w, exp_w, y, z}, opt_args)
      local v = Q.vveq(w, exp_w)
      local r = Q.sum(v)
      local n1, n2 = r:eval()
      assert(n1 == n2)
      ------
      x:delete()
      y:delete()
      z:delete()
      exp_w:delete()
      w:delete()
      v:delete()
      r:delete()
      ---
      assert(cVector.check_all())
      ---
      print("Test t1 succeeded for xqtype/yqtype = ", xqtype, yqtype)
    end
  end
  local post_mem = lgutils.mem_used() 
  assert(pre_mem == post_mem)
  collectgarbage("restart")
  print("Test t1 succeeded")
end
--==========================
tests.t2 = function()
  for _, xqtype in ipairs(xqtypes) do 
    for _, yqtype in ipairs(yqtypes) do
      local x = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, xqtype)
      local y = Q.mk_col({1, 2, 3, 4, 5, 6, 7}, yqtype)
      local z = Scalar.new("10", yqtype)
      local w = Q.ifxthenyelsez(x, y, z)
      local exp_w = Q.mk_col({1, 10, 3, 10, 5, 10, 7, }, yqtype)
      local n1, n2 = Q.sum(Q.vveq(w, exp_w)):eval()
      -- Q.print_csv({w, exp_w}, opt_args)
      assert(n1 == n2)
      print("Test t2 succeeded for xqtype/yqtype = ", xqtype, yqtype)
    end
  end
  print("Test t2 succeeded")
end
--===========================
tests.t3 = function()
  for _, xqtype in ipairs(xqtypes) do 
    for _, yqtype in ipairs(yqtypes) do
      local x = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, xqtype)
      local y = 10
      local z = Q.mk_col({-1, -2, -3, -4, -5, -6, -7}, yqtype)
      local w = Q.ifxthenyelsez(x, y, z)
      local exp_w = Q.mk_col({10, -2, 10, -4, 10, -6, 10}, yqtype)
      local n1, n2 = Q.sum(Q.vveq(w, exp_w)):eval()
      -- Q.print_csv({w, exp_w}, opt_args)
      assert(n1 == n2)
      assert(n1 == n2)
      print("Test t3 succeeded for xqtype/yqtype = ", xqtype, yqtype)
    end
  end
  print("Test t3 succeeded")
end
--===========================
tests.t4 = function()
  local x = Q.mk_col({1, 0, 1, 0, 1, 0, 1}, "BL")
  local y = Scalar.new("10", "I4")
  local z = -10
  local w = Q.ifxthenyelsez(x, y, z)
  local exp_w = Q.mk_col({10, -10, 10, -10, 10, -10, 10}, "I4")
  -- Q.print_csv({w, exp_w}, opt_args)
  local n1, n2 = Q.sum(Q.vveq(w, exp_w)):eval()
  print("Test t4 succeeded")
end
tests.t1()
tests.t2()
tests.t3()
tests.t4()
-- return tests
