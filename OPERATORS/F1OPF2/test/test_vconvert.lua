require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local lgutils = require 'liblgutils'
local cVector = require 'libvctr'


local tests = {}
tests.t1 = function()
 assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
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
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  print("Test t1 succeeded")
end
tests.t_F2 = function()
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local len = 65535
  local start = 0
  local x4 = Q.seq({start = 0, by = 1, qtype = "F4", len = len})
  x4:eval()
  print("XXXXXXXXXX")
  local x2 = Q.vconvert(x4, "F2")
  local y4 = Q.vconvert(x2, "F4")
  y4:eval()
  Q.print_csv({x4, x2, y4}, { opfile = "_x.csv"})
  cVector.check_all()
  x4:delete()
  x2:delete()
  y4:delete()
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  print("Test t1 succeeded")
end
-- tests.t1()
tests.t_F2()
-- return tests
