-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local lgutils = require 'liblgutils'

local tests = {}
tests.t1 = function()
  collectgarbage()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
  local c2 = Q.is_prev(c1, "eq", { default_val = false } )
  c2:eval()
  local r = Q.sum(c2)
  local n1, n2 = r:eval()
  assert(n1:to_num() == 0)
  -- Q.print_csv({c1, c2})
  r:delete()
  c2:delete()

  local c2 = Q.is_prev(c1, "neq", { default_val = true } )
  c2:eval()
  print("=====")
  local r = Q.sum(c2)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  -- Q.print_csv({c1, c2})
  c2:delete()
  r:delete()

  c1:delete()
  local c1 = Q.mk_col( {1,1,1,1,1,1,1,1}, "F8")
  local c2 = Q.is_prev(c1, "eq", { default_val = false } )
  c2:eval()
  local r = Q.sum(c2)
  local n1, n2 = r:eval()
  assert(n1:to_num() == c1:num_elements() -1)
  -- Q.print_csv({c1, c2})
  c2:delete()
  r:delete()
  c2:delete()
  -- cleanup
  c1:delete()

  local post = lgutils.mem_used()
  print(pre,  post)
  assert(pre == post)
  collectgarbage("restart")
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
  assert(n1:to_num() == c1:num_elements() )

  print("Test t2 succeeded")
end

tests.t3 = function()
  local len = 2 * qcfg.max_num_in_chunk + 17
  local c1 = Q.seq( {start = 0, by = 1, qtype = "I4", len = len})

  local c2 = Q.is_prev(c1, "leq", { default_val = true } )
  c2:eval()
  Q.print_csv({c1, c2}, { opfile = "_x" })
  local n1, n2 = Q.sum(c2):eval()
  print(n1, n2)
  assert(n1:to_num() == c1:num_elements())

  local c2 = Q.is_prev(c1, "geq", { default_val = false } )
  local n1, n2 = Q.sum(c2):eval()
  -- Q.print_csv({c1, c2})
  assert(n1:to_num() == 0)

  print("Test t3 succeeded")
end
--return tests
tests.t1()
tests.t2()
tests.t3()
