-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'

local tests = {}
tests.t1 = function()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
  local c2 = Q.mk_col( {20,35,26,50,11,30,45,17}, "I4")
  local z = Q.vvadd(c1, c2)
  -- This is a valid scenario where sort is having input a vector which is not eval'ed
  -- Sort internally does the eval
  local status = pcall(Q.sort, z, "asc")
  --assert(not status )
  z:eval()
  Q.sort(z, "asc")
end
--======================================
return tests
