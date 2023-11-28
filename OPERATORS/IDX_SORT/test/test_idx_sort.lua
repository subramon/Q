-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qtypes = { "I4", "I8", "F4", "F8", }
local tests = {}
--=========================================
tests.t1 = function()
  for _, qtype in ipairs(qtypes) do 
  for _, ordr in ipairs({ "asc", "dsc", }) do 
      local max_num_in_chunk = 64
      local len = 3 * max_num_in_chunk + 17 
      local idx = Q.seq({start = 0, by =1, qtype = "I4", len = len,
        max_num_in_chunk = max_num_in_chunk}):eval()
      local val = Q.rand({ lb = -65537, ub = 65537, qtype = qtype, len = len, 
        max_num_in_chunk = max_num_in_chunk}):eval()
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
      if ( ordr == "asc" ) then cmp = "leq" else cmp = "geq" end 
      local z = Q.is_prev(srt_val, cmp, { default_val = true}):set_name("z")
      local v = Q.sum(z)
      assert(type(v) == "Reducer")
      local n1, n2 = v:eval()
      assert(type(n1) == "Scalar")
      assert(type(n2) == "Scalar")
      -- Q.print_csv({srt_val, z}, { opfile = "_x"})
      assert(n1 == n2)
      print("Test t1 OK for qtype = " .. qtype .. " ordr = " .. ordr)
    end
  end
  print("Test t1 succeeded")

end
tests.t1()
-- return tests
