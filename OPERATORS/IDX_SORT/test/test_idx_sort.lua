-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local tests = {}
--=========================================
tests.t1 = function()
  local len = 1048576 + 65537
  local val = Q.rand({ lb = -65537, ub = 65537, qtype = "I4", len = len}):eval()
  local idx = Q.seq({start = 0,by =1, qtype = "I4", len = len}):eval()
  Q.idx_sort(idx, val, "ascending")
  -- if we now sort idx in ascending order it should get back 
  -- to where it was before
  assert(
    Q.sum(
      Q.vveq(
        Q.sort(idx, "ascending"), 
        Q.seq({start = 0,by =1, qtype = "I4", len = len})
      )
    ):eval():to_num() == len
  )
  -- Verify whether val it is in fact ascending
  local x = Q.is_next(val, "geq")
  assert(type(x) == "Reducer")
  local a, b = x:eval()
  assert(type(a) == "boolean")
  assert(type(b) == "number")
  assert(a == true)
  assert(b == len)
  -- assert(Q.is_next(val, "geq"):eval() == true)
  print("Test t1 succeeded")
  -- local opt_args = { opfile = "" }
  -- Q.print_csv({val, idx}, opt_args)

end
--=========================================
tests.t2 = function()
  local len = 1048576 + 65537
  local val = Q.rand({ lb = -65537, ub = 65537, qtype = "I4", len = len})
  local idx = Q.seq({start = 0,by =1, qtype = "I4", len = len})
  Q.idx_sort(idx, val, "ascending")
  -- if we now sort idx in ascending order it should get back
  -- to where it was before
  assert(
    Q.sum(
      Q.vveq(
        Q.sort(idx, "ascending"),
        Q.seq({start = 0,by =1, qtype = "I4", len = len})
      )
    ):eval():to_num() == len
  )
  -- Verify whether val it is in fact ascending
  local x = Q.is_next(val, "geq")
  assert(type(x) == "Reducer")
  local a, b = x:eval()
  assert(type(a) == "boolean")
  assert(type(b) == "number")
  assert(a == true)
  assert(b == len)
  -- assert(Q.is_next(val, "geq"):eval() == true)
  print("Test t2 succeeded")
  -- local opt_args = { opfile = "" }
  -- Q.print_csv({val, idx}, opt_args )

end
return tests
