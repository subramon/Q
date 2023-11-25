require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local Scalar  = require 'libsclr'
local orders  = require 'Q/OPERATORS/F_IN_PLACE/lua/orders'
local qtypes  = require 'Q/OPERATORS/F_IN_PLACE/lua/qtypes'
local cVector = require 'libvctr'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local lgutils = require 'liblgutils'
local tests = {}
tests.t1 = function()
  -- Set up some vals that work for all qtypes
  for whynot = 1, 2 do -- call twice to test dynamic compilation
    for iter = 1, 2 do
      local vals = {}
      local n = 0
      local lb, ub, incr
      if ( iter == 1 ) then
        lb = -128
        ub = 127
        incr = 1
      elseif ( iter == 2 ) then
        lb = 127
        ub = -128
        incr = -1
      else
        error("")
      end
      for val = lb, ub, incr do
        vals[#vals+1] = val
        n = n + 1
      end
      for _, order in ipairs(orders) do
        for _, qtype in ipairs(qtypes) do
          local x = Q.mk_col(vals, qtype):eval()
          assert(x:num_elements() == n)
          local y = Q.sort(x, order)
          assert(type(y) == "lVector")
          assert(x:qtype() == y:qtype())
          assert(x:uqid() ~= y:uqid())
          assert(y:get_meta("sort_order") == order)
          local xlb, xub, xincr
          if ( order == "asc" ) then
            xlb = -128
            xub =  127
            xincr = 1
          else
            xlb =  127
            xub = -128
            xincr = -1
          end
          local i = 0
          for xval = xlb, xub, xincr do
            assert(y:get1(i) == Scalar.new(xval, qtype))
            i = i + 1
          end
          x:delete()
          y:delete()
        end
      end
    end
  end
  assert(cVector.check_all())
  print("Successfully completed test t1")
end
tests.t2 = function()
  local len = 1048576 
  local args = {
  len = len,
  start = 1, by = 1,
  period = 127,
}

local qtypes = { "I1", "I2", "I4", "I8", } 
  for _, order in ipairs(orders) do
    for _, qtype in ipairs(qtypes) do
      args.qtype = qtype 
      local x = Q.period(args):set_name("x" .. qtype):eval()
      local y = Q.sort(x, order):set_name("y" .. qtype)
      assert(y:check())
      assert(type(y) == "lVector")
      y = y:lma_to_chunks() -- sort needs lma, but is_prev needs chunks
      assert(y:is_lma() == false)
      assert(y:check())
      assert(x:num_chunks() == y:num_chunks())
      assert(x:num_elements() == y:num_elements())
      print("XXX", x:num_elements(),  y:num_elements())
      print("XXX", x:num_chunks(),  y:num_chunks())
      local cmp
      if ( order == "asc" ) then cmp = "lt" else cmp = "gt" end 
      y:set_name("sorty")
      local z = Q.is_prev(y, cmp, { default_val = false})
      z:set_name("z" .. qtype)
      local v = Q.sum(z)
      assert(type(v) == "Reducer")
      local n1, n2 = v:eval()
      assert(type(n1) == "Scalar")
      assert(type(n2) == "Scalar")
      assert(n1:to_num() == 0)
      x:delete()
      y:delete()
      z:delete()
      v:delete()
      print("Successfully completed test t2 for ", order, qtype)
    end
  end
  assert(cVector.check_all())
  print("Successfully completed test t2")
end
tests.t3 = function()
  local len = 128
  local max_num_in_chunk = 64
  local args = {
  len = len,
  max_num_in_chunk = max_num_in_chunk, 
  start = 1, 
  by = 1,
}

local qtypes = { "F4", "F8" }
  for _, order in ipairs(orders) do
    for _, qtype in ipairs(qtypes) do
      args.qtype = qtype 
      local x = Q.seq(args):eval()
      assert(x:check())
      assert(x:num_readers(0) == 0) 
      assert(not x:is_lma())
      local yname = "y_" .. order .. "_" .. qtype
      local y = Q.sort(x, order):set_name(yname)
      assert(y:check())
      assert(y:is_lma())
      y = y:lma_to_chunks() -- sort needs lma, but is_prev needs chunks
      assert(not y:is_lma())
      local cmp
      print("Y num_in_c = ", y:max_num_in_chunk())
      --==================================
      if ( order == "asc" ) then cmp = "lt" else cmp = "gt" end 
      local zname = "z_" .. order .. "_" .. qtype
      local z = Q.is_prev(y, cmp, { default_val = false}):set_name(zname)
      assert(z:qtype() == "BL")
      z:eval() -- TODO P0 TEST 
      local u = Q.sum(z)
      assert(type(u) == "Reducer")
      local n1, n2 = u:eval()
      assert(type(n1) == "Scalar")
      assert(type(n2) == "Scalar")
      assert(n1:to_num() == 0)
      --==================================
      if ( order == "asc" ) then cmp = "gt" else cmp = "lt" end 
      local wname = "w_" .. order .. "_" .. qtype
      local w = Q.is_prev(y, cmp, { default_val = true}):set_name(wname)
      local v      = Q.sum(w)
      assert(type(v) == "Reducer")
      local n1, n2 = v:eval()
      assert(type(n1) == "Scalar")
      assert(type(n2) == "Scalar")
      assert(n1 == n2)
      --==================================
      x:delete()
      y:delete()
      z:delete()
      w:delete()
      v:delete()
      u:delete()
      print("Successfully completed test t2 for ", order, qtype)
    end
  end
  assert(cVector.check_all())
  print("Successfully completed test t3")
end
-- WORKS tests.t1()
-- WORKS tests.t2()
tests.t3()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
