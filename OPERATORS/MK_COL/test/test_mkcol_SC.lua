-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local cVector = require 'libvctr'
cVector.init_globals({})
local Scalar = require 'libsclr'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'

local tests = {}
tests.t1 = function()
  local ys = {"abc", "defg", "hijkl"}
  local x = mk_col(ys, "SC")
  assert(x:length() == #ys)
  for i, y in pairs(ys) do 
    local s = x:get1(i-1)
    assert(type(s) == "CMEM")
    assert(s:to_str("SC") == y)
  end
  print("Test t1 succeeded")
end
return tests
-- tests.t1()
