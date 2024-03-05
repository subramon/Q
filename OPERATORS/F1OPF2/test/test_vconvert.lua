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
tests.t3 = function()
  local pre_mem = lgutils.mem_used()
  local len = 16 
  local in_qtype = "UI8"
  local x = Q.seq({start = 0, by = 1, qtype = in_qtype, len = len})
  local y = Q.vsmul(x, 4096*1048576)
  local z = Q.vvadd(y, x)
  local w = Q.vconvert(z, "UI4")
  local v = Q.vveq(w, x)
  local r = Q.sum(v)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  -- Q.print_csv({x, y, z, w})
 
  x:delete()
  y:delete()
  z:delete()
  w:delete()
  v:delete()
  r:delete()
  local post_mem = lgutils.mem_used()
  assert(pre_mem == post_mem)
  print("Test t3 succeeded")
end
tests.t1()
tests.t_F2()
tests.t3()
-- return tests
