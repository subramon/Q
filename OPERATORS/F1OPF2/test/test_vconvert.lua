require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local lgutils = require 'liblgutils'

local tests = {}
tests.t1 = function()
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
  print("Test t1 succeeded")
end
tests.t1()
collectgarbage()
-- print("MEM", lgutils.mem_used()); print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
