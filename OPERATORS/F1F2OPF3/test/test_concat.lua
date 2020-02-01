-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local cVector = require 'libvctr'
cVector.init_globals({})

local tests = {}
tests.t1 = function()
  local len = 13
  local c1 = Q.seq( {len = len, start = 1, by = 1, qtype = "I4"})
  local c2 = Q.concat(c1, c1)
  -- Q.print_csv({c1, c2})
local c3 = Q.mk_col( {
4294967297,
8589934594,
12884901891,
17179869188,
21474836485,
25769803782,
30064771079,
34359738376,
38654705673,
42949672970,
47244640267,
51539607564,
55834574861,
}, "I8")
  local n1, n2 = Q.sum(Q.vveq(c2, c3)): eval()
  assert(n1:to_num() == c2:length())
  assert(n2:to_num() == c2:length())
  print("Test t1 succeeded")
end

return tests
