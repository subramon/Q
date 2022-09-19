-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'

local tests = {}
tests.t1 = function()
  local ys = {"abc", "defg", "hijkl"}
  local x = mk_col(ys, "SC")
  assert(x:num_elements() == #ys)
  for i, y in pairs(ys) do 
    local s = x:get1(i-1)
    assert(type(s) == "Scalar")
    assert(s:to_str("SC") == y)
  end
  x:eov()
  x:pr()
  print("Test t1 succeeded")
end
-- return tests
tests.t1()
