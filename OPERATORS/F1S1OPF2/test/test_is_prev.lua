-- FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
  local c2 = Q.is_prev(c1, "eq", { default_val = false } )
  c2:eval()
  c2:pr()
  print("=====")
  -- TODO local n1, n2 = Q.sum(c2):eval()
  -- TODO assert(n1:to_num() == 0)
  -- TODO Q.print_csv({c1, c2})

  local c2 = Q.is_prev(c1, "eq", { default_val = true } )
  c2:eval()
  c2:pr()
  print("=====")
  -- TODO local n1, n2 = Q.sum(c2):eval()
  -- TODO Q.print_csv({c1, c2})
  -- TODO assert(n1:to_num() == 1)
  local c1 = Q.mk_col( {1,1,1,1,1,1,1,1}, "F8")
  local c2 = Q.is_prev(c1, "eq", { default_val = false } )
  c2:eval()
  c2:pr()
  print("=====")

  print("Test t1 succeeded")
end
tests.t2 = function()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")

  local c2 = Q.is_prev(c1, "geq", { default_val = false } )
  local n1, n2 = Q.sum(c2):eval()
  Q.print_csv({c1, c2})
  assert(n1:to_num() == 0)

  local c2 = Q.is_prev(c1, "leq", { default_val = true } )
  local n1, n2 = Q.sum(c2):eval()
  Q.print_csv({c1, c2})
  assert(n1:to_num() == c1:length() )

  print("Test t2 succeeded")
end

tests.t3 = function()
  local len = 2 * qcfg.max_num_in_chunk + 17
  local c1 = Q.seq( {start = 0, by = 1, qtype = "I4", len = len})

  local c2 = Q.is_prev(c1, "leq", { default_val = true } )
  -- Q.print_csv({c1, c2})
  local n1, n2 = Q.sum(c2):eval()
  assert(n1:to_num() == c1:length())

  local c2 = Q.is_prev(c1, "geq", { default_val = false } )
  local n1, n2 = Q.sum(c2):eval()
  -- Q.print_csv({c1, c2})
  assert(n1:to_num() == 0)

  print("Test t3 succeeded")
end
--return tests
tests.t1()
