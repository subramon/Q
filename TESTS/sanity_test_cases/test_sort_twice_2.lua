local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function() 
  local x = Q.seq({start = -1000000, by = 1, qtype = "I4", len = 2000000} )
  assert(type(x) == "lVector")
  -- With recent changes, sort doesn't required vector to be eval'ed
  -- it does eval internally if vector is not eval'ed already
  local status = pcall(Q.sort, x, "asc")
  --assert(not status)
  x:eval()
  Q.sort(x, "dsc")
  Q.sort(x, "asc")
  assert(Q.sum(Q.vveq(x, Q.seq({start = -1000000, by = 1, qtype = "I4", len = 2000000}))):eval():to_num() == x:length())
end

--======================================

return tests
