-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local json = require 'Q/UTILS/lua/json'
local tests = {}
tests.t1 = function()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
  local c2 = Q.mk_col( {20,35,26,50,11,30,45,17}, "I4")
  local x, y = Q.view_meta()
  assert(type(x) == "table")
  local w = assert(json.parse(y))
end
--======================================
return tests
