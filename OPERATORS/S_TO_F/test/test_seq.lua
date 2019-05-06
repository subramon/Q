-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local tests = {}

tests.t1 = function()
-- TODO Write one with a much larger A and B vector
  local len = 1000000
  local b = Q.seq({ len = len, start = 1, by = 2, qtype = "I4"})
  local a = Q.seq({ len = len, start = 1, by = 1, qtype = "I4"})
  a:eval()
  local opt_args = { opfile = "/tmp/_foo.txt" }
  Q.print_csv(a, opt_args)
  assert(Q.min(a):eval():to_num() == 1 )
  assert(Q.min(b):eval():to_num() == 1 )

  assert(Q.max(a):eval():to_num() == len)
  assert(Q.max(b):eval():to_num() == 2*len-1)

  print("Test t1 succeeded")
end
return tests
