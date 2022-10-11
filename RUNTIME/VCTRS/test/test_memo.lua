local Q = require 'Q'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'

local tests = {}
tests.t1 = function()
  local max_num_in_chunk = 64 
  local len = 3 * max_num_in_chunk + 7
  x1 = Q.seq({ len = len, start = 1, by = 1, qtype = "I4",
   name = "x1", max_num_in_chunk = max_num_in_chunk, memo_len = 1 })
  assert(x1:memo_len() == 1)
  assert(x1:name() == "x1")

  y1 = Q.concat(x1, x1, { name = "y1", f3_qtype = "I8", shift_by = 32})
  y2 = Q.concat(x1, x1, { name = "y2", f3_qtype = "I8", shift_by = 16})
  lVector.conjoin({y1, y2})
  y1:eval()
  assert(y1:num_elements() == x1:num_elements())
  assert(y1:num_elements() == y2:num_elements())
  assert(cVector.check_all(true, true))
  Q.save()
  x = nil; y1 = nil; y2 = nil; collectgarbage()
  print("Test t1 succeeded")
end
-- return tests
tests.t1()
-- os.exit()
