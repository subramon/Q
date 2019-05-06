-- FUNCTIONAL 
local Q = require 'Q'
-- deliberate comment to allow for globals require 'Q/UTILS/lua/strict'
local tests = {}
--=========================================
tests.t1 = function()
  local n = 1048576+17
  y = Q.seq({start = 1, by = 1, qtype = "I4", len = n })
  local n1, n2 = Q.sum(y):eval()
  y:set_meta("sum", {n1, n2} )
  local r = Q.sum(y)
  assert(type(r) == "Reducer")
  local m1, m2 = r:eval()
  assert(m1 == n1)
  assert(m2 == n2)
  print("Test t1 succeeded")
  y:persist()
  Q.save("/tmp/foo.meta")
  y:delete()
  Q.restore("/tmp/foo.meta")
  local t = y:get_meta("sum")
  assert(type(t) == "table")
  assert(#t == 2)

end
--=========================================
return tests
