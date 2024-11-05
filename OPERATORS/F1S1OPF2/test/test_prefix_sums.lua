-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local lgutils = require 'liblgutils'

local tests = {}
tests.t1 = function()
  collectgarbage()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
  local c2 = Q.prefix_sums(c1)
  c2:eval()
  local chk_c2 = Q.mk_col( {1,3,6,10,15,21,28,36}, "I4")
  Q.print_csv({c1, c2, chk_c2})
  local x = Q.vveq(c2, chk_c2)
  local r = Q.sum(x)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  r:delete()
  x:delete()
  c1:delete()
  c2:delete()
  chk_c2:delete()

  local post = lgutils.mem_used()
  print(pre,  post)
  assert(pre == post)
  collectgarbage("restart")
  print("Test t1 succeeded")
end
--return tests
-- tests.t1()
tests.t1()
