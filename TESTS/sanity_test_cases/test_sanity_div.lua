-- This test checks that division of a vector by null vector dies with "floating point expection" error.
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()
  -- SANITY TEST
  local a = Q.mk_col({1, 2, 3}, "I4")
  local b = Q.mk_col({0, 0, 0}, "I4")
  local c = Q.vvdiv(a, b)
  assert(type(c) == "lVector")
end

--=======================================

return tests
