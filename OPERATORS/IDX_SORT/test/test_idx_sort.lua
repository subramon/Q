-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local tests = {}
--=========================================
tests.t1 = function()
  local max_num_in_chunk = 64
  local len = 3 * max_num_in_chunk + 17 
  local idx = Q.seq({start = 0, by =1, qtype = "I4", len = len,
    max_num_in_chunk = max_num_in_chunk}):eval()
  local val = Q.rand({ lb = -65537, ub = 65537, qtype = "I4", len = len, 
    max_num_in_chunk = max_num_in_chunk}):eval()
  local ordr = "ascending"
  local srt_idx, srt_val = Q.idx_sort(idx, val, ordr)
  assert(type(srt_idx) == "lVector")
  assert(type(srt_val) == "lVector")
  assert(srt_idx:is_lma())
  assert(srt_val:is_lma())
  srt_idx = srt_idx:lma_to_chunks()
  srt_val = srt_val:lma_to_chunks()
  assert(srt_idx:max_num_in_chunk() == max_num_in_chunk)
  assert(srt_val:max_num_in_chunk() == max_num_in_chunk)
  -- if we now sort idx in ascending order it should get back 
  -- to where it was before
  local srt_srt_idx = Q.sort(srt_idx, "asc")
  srt_srt_idx = srt_srt_idx:lma_to_chunks()
  local n1, n2 = Q.sum(Q.vveq(idx, srt_srt_idx)):eval()
  assert(n1 == n2)
  -- Verify whether val it is in fact ascending
  local cmp
  if ( ordr == "asc" ) then cmp = "lt" else cmp = "gt" end 
  local z = Q.is_prev(srt_val, cmp, { default_val = true}):set_name("z")
  local v = Q.sum(z)
  assert(type(v) == "Reducer")
  local n1, n2 = v:eval()
  assert(type(n1) == "Scalar")
  assert(type(n2) == "Scalar")
  assert(n1 == n2)
  Q.print_csv({srt_val, z}, { opfile = "_x"})
  print("Test t1 succeeded")

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
tests.t1()
-- TODO tests.t2()
-- return tests
