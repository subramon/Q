require 'Q/UTILS/lua/strict'
local Q      = require 'Q'

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

  local y = Q.sum(Q.vveq(x, notx))
  local n1, n2 = y:eval()
  assert(n1:to_num() == 0)

  local y = Q.sum(Q.vveq(chk_notx, notx))
  local n1, n2 = y:eval()
  assert(n1:to_num() == n2:to_num())

  print("Test t1 succeeded")
end
tests.t1()
os.exit()
-- return tests
