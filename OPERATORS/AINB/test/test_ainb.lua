-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local tests = {}
local script_dir = os.getenv("Q_SRC_ROOT") .. "/OPERATORS/AINB/test/"
tests.t1 = function() 
  local b = Q.mk_col({-2, 0, 2, 4 }, "I4")
  local a = Q.mk_col({-2, -2, -1, -1, 0, 1, 1, 2, 2, 3, 3}, "I4")
  local c = Q.ainb(a, b)
  local n = Q.sum(c):eval():to_num()
  assert(n == 5)
  local opt_args = { opfile = "/tmp/_out1.txt" }
  Q.print_csv({a, c}, opt_args)
  -- prepending script_dir so that this test will work from any location
  local f1 = plfile.read(script_dir .. "out1.txt")
  local f2 = plfile.read("/tmp/_out1.txt")
  assert(f1 == f2)
  print("Test t1 succeeded")
end

tests.t2 = function()
-- TODO Write one with a much larger A and B vector
  local vec_len = 65536 + 11
  local b = Q.seq({ len = vec_len, start = 1, by = 2, qtype = "I8"})
  b:eval()
  b:set_meta("sort_order", "asc") 
  local a = Q.seq({ len = vec_len, start = 1, by = 1, qtype = "I8"}):set_name("a")
  local c = Q.ainb(a, b):set_name("c")
  -- local opt_args = { opfile = "_xx.csv" }
  -- Q.print_csv({a,b,c}, opt_args)
  local n = Q.sum(c):eval():to_num()
  local expected_n = math.ceil(vec_len / 2)
  print("n, expected_n, len", n, expected_n, vec_len)
  assert(n == expected_n)
end

tests.t3 = function()
  local vec_len = 65
  local b = Q.seq({ len = vec_len, start = 1, by = 2, qtype = "I8"})
  b:set_meta("sort_order", "asc") 
  local a = Q.seq({ len = vec_len, start = 1, by = 1, qtype = "I8"}):set_name("a")
  local c = Q.ainb(a, b):set_name("c")
  local n = Q.sum(c):eval():to_num()
  local expected_n = math.ceil(vec_len / 2)
  print("n, expected_n, len", n, expected_n, vec_len)
  assert(n == expected_n)
end

tests.t1()

-- return tests
