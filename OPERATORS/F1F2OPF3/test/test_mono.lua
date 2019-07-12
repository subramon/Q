-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'

local tests = {}
tests.t1 = function()
  local n = qconsts.chunk_size * 3 + 17
  local c1 = Q.const({ val = 1, qtype = "F8", len = n}):set_name("c1"):memo():mono()
  local c2 = Q.const({ val = 2, qtype = "F8", len = n}):set_name("c2"):memo():mono()
  local c3 = Q.vvadd(c1, c2):set_name("c3"):persist(true)
  Q.print_csv(c3, { opfile = "/tmp/_xx.csv"})
  assert(c1:is_dead())
  assert(c2:is_dead())
  print("Test t1 succeeded")
end
return tests
-- tests.t1()
