-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'
local tests = {}
tests.t1 = function() 
  collectgarbage("stop")
  local pre_mem = lgutils.mem_used(); local pre_dsk = lgutils.dsk_used()
  local b = Q.mk_col({-2, 0, 2, 4 }, "I4")
  local a = Q.mk_col({-2, -2, -1, -1, 0, 1, 1, 2, 2, 3, 3}, "I4")
  local chk = Q.mk_col({true, true, false, false, true, false, false, true, true, false, false, }, "BL")
  local c = Q.get_idx_by_val(a, b)
  local nn_c = c:get_nulls()
  local n = Q.sum(nn_c):eval():to_num()
  assert(n == 5)
  local z = Q.vveq(nn_c, chk)
  local r = Q.sum(z)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  a:delete()
  b:delete()
  c:delete()
  chk:delete()
  nn_c:delete()
  z:delete()
  r:delete()

  local post_mem = lgutils.mem_used(); local post_dsk = lgutils.dsk_used()
  assert(pre_mem == post_mem)
  assert(pre_dsk == post_dsk)
  collectgarbage("restart")
  assert(cVector.check_all())
  print("Test t1 succeeded")
end
-- return tests
tests.t1()
