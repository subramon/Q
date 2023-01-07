-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local Scalar  = require 'libsclr'
local lgutils = require 'liblgutils'

local tests = {}
tests.t1 = function()

  assert(Q.register)
  Q.register("Q/OPERATORS/F1F2OPF3/lua/expander_f1f2opf3", "hypot")
  assert(Q.hypot)
  assert(type(Q.hypot) == "function")
  local optargs = { max_num_in_chunk  = 64 , }
  local len = 2 * optargs.max_num_in_chunk + 3
  local qtypes = { "I1","I2", "I4", "I8", "F4", "F8", } 
  for _, qtype in pairs(qtypes) do
    local x1 = {}; for i = 1, len do x1[i] = 3 end
    local x2 = {}; for i = 1, len do x2[i] = 4 end
    local x3 = {}; for i = 1, len do x3[i] = 5 end
    print("Testing hypot with qtype = " .. qtype)
    local c1 = Q.mk_col(x1, qtype, optargs)
    local c2 = Q.mk_col(x2, qtype, optargs)
    local c3 = Q.mk_col(x3, "F8", optargs)
    local z = Q.hypot(c1, c2):eval()
    assert(z:qtype() == "F8")
    --[[
    for i = 1, len do 
      assert(z:get1(i-1) == c3:get1(i-1))
      local diff = math.abs(z:get1(i-1):to_num() - c3:get1(i-1):to_num())
      assert(diff < 0.001)
    end
    --]]
    c1:delete() 
    c2:delete()
    c3:delete()
    z:delete()
    print("Test t1 succeeded for qtype ", qtype)
  end
  print("Test t1 succeeded")
end
tests.t1()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
