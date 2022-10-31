local Q = require 'Q'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'

local tests = {}
tests.t1 = function()
  local max_num_in_chunk = 16 
  local len = 3 * max_num_in_chunk + 7
  x1 = Q.seq({ len = len, start = 1, by = 1, qtype = "I4",
    name = "x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  print(">>> START DELIBERATE ERROR")
  local status = pcall(lVector.chunks_to_lma, x1)
  assert(not status)
  print(">>> STOP  DELIBERATE ERROR")
  x1:eval()
  for i = 1, 1000 do 
    assert(x1:chunks_to_lma())
    assert(x1:del_lma())
  end
  print("Test t1 succeeded")
end
-- return tests
tests.t1()
-- os.exit()
