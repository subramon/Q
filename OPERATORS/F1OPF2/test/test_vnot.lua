require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local lgutils = require 'liblgutils'

local tests = {}
tests.t1 = function()
  local len = 255
  local vals1 = {}
  local toggle = true
  for i = 1, len do 
    if ( toggle ) then vals1[i] = true else vals[i] = false end 
  end

  local vals2 = {}
  for i = 1, len do 
    vals2[i] = not  vals1[i] 
  end

  local x = Q.mk_col(vals1, "BL")
  local chk_notx = Q.mk_col(vals2, "BL"):eval()
  local notx = Q.vnot(x)

  local y1 = Q.vveq(x, notx)
  local y2 = Q.sum(y1)
  local n1, n2 = y2:eval()
  assert(n1:to_num() == 0)

  local z1 = Q.vveq(chk_notx, notx)
  local z2 = Q.sum(z1)
  local n1, n2 = z2:eval()
  assert(n1:to_num() == n2:to_num())

  x:delete()
  y1:delete()
  y2:delete()
  z1:delete()
  z2:delete()
  print("Test t1 succeeded")
end
tests.t1()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
