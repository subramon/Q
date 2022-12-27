--FUNCTIONAL TEST
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'
local plfile  = require 'pl.file'

local tests = {}

tests.t1 = function()
  local correct = {}
  local c1         = Q.mk_col ({0,0,1,1}, "I1")
  local c2         = Q.mk_col ({0,1,0,1}, "I1")
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
  end
  print("Test t1 succeeded")
end
-- return tests
tests.t1()
os.exit()
