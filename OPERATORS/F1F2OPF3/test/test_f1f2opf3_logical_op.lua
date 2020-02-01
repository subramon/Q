--FUNCTIONAL TEST
require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local cVector = require 'libvctr'
cVector.init_globals({})
local plfile = require 'pl.file'

local tests = {}

tests.t1 = function()
  local correct = {}
  local c1         = Q.mk_col ({0,0,1,1}, "B1")
  local c2         = Q.mk_col ({0,1,0,1}, "B1")
  correct.vvand    = Q.mk_col ({0,0,0,0}, "B1")
  correct.vvor     = Q.mk_col ({1,1,1,1}, "B1")
  correct.vvandnot = Q.mk_col ({0,0,1,0}, "B1")
  local n = #c1
  local operators = { "vvand", "vvor", "vvandnot" }
  for _, operator in pairs(operators) do 
    local c3 = Q.vvand(c1, c2, { junk = "junk" } )
    c3:eval()
    for i = 1, n do 
      local x = c3:get1(i-1)
      assert(x == correct[operator]:get1(i-1))
    end
  end
  print("Test t1 succeeded")
end

return tests
-- tests.t1()
-- os.exit
