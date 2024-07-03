--FUNCTIONAL TEST
local plfile  = require 'pl.file'
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'
local lgutils = require 'liblgutils'

local tests = {}

tests.t1 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  for iter = 1, 2 do 
    local correct = {}
    local nn1, nn2
    local c1         = Q.mk_col ({0,0,1,1}, "I1")
    local c2         = Q.mk_col ({0,1,0,1}, "I1")
    if ( iter == 2 ) then 
      nn1 = Q.mk_col ({true,false,true,false}, "BL"):set_name("nn1")
      nn2 = Q.mk_col ({true,false,true,false}, "BL"):set_name("nn2")
      c1:set_nulls(nn1)
      c2:set_nulls(nn2)
    end
    correct.vvand    = Q.mk_col ({0,0,0,0}, "I1")
    correct.vvor     = Q.mk_col ({1,1,1,1}, "I1")
    correct.vvandnot = Q.mk_col ({0,0,1,0}, "I1")
    correct.vvxor    = Q.mk_col ({0,1,1,0}, "I1")
    local n = #c1
    local operators = { "vvand", "vvor", "vvandnot","vvxor" }
    for _, operator in pairs(operators) do 
      print("Testing " .. operator)
      local c3 = Q[operator](c1, c2):eval()
      for i = 1, n do 
        assert(c3:get1(i-1) == correct[operator]:get1(i-1))
      end
      c3:delete()
    end
    if ( iter == 2 ) then 
      assert(c1:has_nulls())
      assert(c2:has_nulls())
    end
    c1:delete()
    c2:delete()
    correct.vvand:delete()
    correct.vvor:delete()
    correct.vvandnot:delete()
    correct.vvxor:delete()
    print("Test t1 succeeded for iteration", iter)
  end
  local post = lgutils.mem_used()
  cVector.hogs("mem")
  assert(pre == post)
  collectgarbage()
  print("Test t1 succeeded")
end
-- return tests
tests.t1()
