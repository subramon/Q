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
          assert(x:length() == n)
          x:master() -- TODO P3 Delete later
          Q.sort(x, order)
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
            assert(x:get1(i) == Scalar.new(xval, qtype))
            i = i + 1
          end
        end
      end
    end
  end
  print("Successfully completed test t1")
end
-- tests.t1()
-- os.exit()
return tests
