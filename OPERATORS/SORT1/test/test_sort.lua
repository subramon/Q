require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local Scalar = require 'libsclr'
local orders = require 'Q/OPERATORS/F_IN_PLACE/lua/orders'
local qtypes = require 'Q/OPERATORS/F_IN_PLACE/lua/qtypes'
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
        end
      end
    end
  end
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
      local x = Q.period(args):eval()
      local y = Q.sort(x, order)
      local cmp
      if ( order == "asc" ) then cmp = "lt" else cmp = "gt" end 
      local z = Q.is_prev(y, cmp, { default_val = false})
      local n1, n2 = Q.sum(z):eval()
      assert(type(n1) == "Scalar")
      assert(type(n2) == "Scalar")
      assert(n1:to_num() == 0)
      print("Successfully completed test t2 for ", order, qtype)
    end
  end
  print("Successfully completed test t2")
end
tests.t3 = function()
  local len = 1048576 
  local args = {
  len = len,
  start = 1, 
  by = 1,
}

local qtypes = { "F4", "F8" }
  for _, order in ipairs(orders) do
    for _, qtype in ipairs(qtypes) do
      args.qtype = qtype 
      local x = Q.seq(args):eval()
      local y = Q.sort(x, order)
      local cmp
      if ( order == "asc" ) then cmp = "lt" else cmp = "gt" end 
      local z = Q.is_prev(y, cmp, { default_val = false})
      local n1, n2 = Q.sum(z):eval()
      assert(type(n1) == "Scalar")
      assert(type(n2) == "Scalar")
      assert(n1:to_num() == 0)
      print("Successfully completed test t2 for ", order, qtype)
    end
  end
  print("Successfully completed test t3")
end
tests.t1()
tests.t2()
tests.t3()
-- return tests