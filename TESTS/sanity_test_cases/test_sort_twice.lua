-- Test sort behaviour of Q
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  -- TEST SORT TWICE TEST
  local x = Q.mk_col({10,50,40,30}, 'I4')
  local y = Q.mk_col({10,30,40,50}, 'I4')
  local z = Q.mk_col({50,40,30,10}, 'I4')
  assert(type(x) == "lVector")
  assert(type(y) == "lVector")
  assert(type(z) == "lVector")
  -- Dsc & Asc = Asc
  Q.sort(x, "dsc")
  Q.sort(x, "asc")
  local s1 = Q.vveq(x, y)
  assert(type(s1) == "lVector")
  assert(Q.sum(s1):eval():to_num() == y:length())
  -- Asc & Dsc = Dsc
  local x = Q.mk_col({10,50,40,30}, 'I4')
  Q.sort(x, "asc")
  Q.sort(x, "dsc")
  local s2 = Q.vveq(x, z)
  assert(type(s2) == "lVector")
  assert(Q.sum(s2):eval():to_num() == z:length())
end

--======================================

return tests
