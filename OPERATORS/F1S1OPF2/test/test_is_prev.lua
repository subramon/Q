-- FUNCTIONAL
local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")

  local c2 = Q.is_prev(c1, "eq", { default_val = 0 } )
  local n1, n2 = Q.sum(c2):eval()
  assert(n1:to_num() == 0)
  Q.print_csv({c1, c2})

  local c2 = Q.is_prev(c1, "eq", { default_val = 1 } )
  local n1, n2 = Q.sum(c2):eval()
  Q.print_csv({c1, c2})
  assert(n1:to_num() == 1)

  print("Test t1 succeeded")
end
tests.t2 = function()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")

  local c2 = Q.is_prev(c1, "geq", { default_val = 0 } )
  local n1, n2 = Q.sum(c2):eval()
  Q.print_csv({c1, c2})
  assert(n1:to_num() == 0)

  local c2 = Q.is_prev(c1, "leq", { default_val = 1 } )
  local n1, n2 = Q.sum(c2):eval()
  Q.print_csv({c1, c2})
  assert(n1:to_num() == c1:length() )

  print("Test t2 succeeded")
end

tests.t3 = function()
  local len = 2 * qconsts.chunk_size + 17
  local c1 = Q.seq( {start = 0, by = 1, qtype = "I4", len = len})

  local c2 = Q.is_prev(c1, "leq", { default_val = 1 } )
  -- Q.print_csv({c1, c2})
  local n1, n2 = Q.sum(c2):eval()
  assert(n1:to_num() == c1:length())

  local c2 = Q.is_prev(c1, "geq", { default_val = 0 } )
  local n1, n2 = Q.sum(c2):eval()
  -- Q.print_csv({c1, c2})
  assert(n1:to_num() == 0)

  print("Test t3 succeeded")
end
return tests
