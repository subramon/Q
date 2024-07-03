-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local cutils = require 'libcutils'
local Q = require 'Q'
local qtypes = { "I4", "I8", "F4", "F8", }
local tests = {}
local qcfg = require 'Q/UTILS/lua/qcfg'
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
      local srt_idx, srt_val = Q.drg_sort(idx, val, ordr)
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
tests.t2 = function()
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "val", qtype = "I8", has_nulls = false}
  M[#M+1] = { name = "idx", qtype = "I4", has_nulls = false}
  local datafile = qcfg.q_src_root .. "/OPERATORS/DRG_SORT/test/test1.csv"
  assert(cutils.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  T.val:eval()
  local srt_idx, srt_val = Q.drg_sort(T.idx, T.val, "asc")
  srt_idx = srt_idx:lma_to_chunks()
  srt_val = srt_val:lma_to_chunks()
  local tcin = Q.shift_right(srt_val, 33):eval()
  Q.print_csv({tcin, srt_val, srt_idx}, { opfile = "_temp.csv"})
  print("Test t2 completed")
end

tests.t3 = function() -- test where F4, F8 are drag along 
  local O = { is_hdr = true }
  local val_qtypes = { 
    "I1",  "I2",  "I4",  "I8", "UI1",  "UI2",  "UI4",  "UI8",  "F4", "F8", }
  local drg_qtypes = { 
    "I1",  "I2",  "I4",  "I8", "UI1",  "UI2",  "UI4",  "UI8",  "F4", "F8", }
  for k1, val_qtype in ipairs(val_qtypes) do 
    for k2, drg_qtype in ipairs(drg_qtypes) do 
      local M = {}
      M[#M+1] = { name = "val", qtype = val_qtype, has_nulls = false}
      M[#M+1] = { name = "drg", qtype = drg_qtype, has_nulls = false}
      M[#M+1] = { name = "chk_val", qtype = val_qtype, has_nulls = false}
      M[#M+1] = { name = "chk_drg", qtype = drg_qtype, has_nulls = false}
      local datafile = qcfg.q_src_root .. "/OPERATORS/DRG_SORT/test/testF.csv"
      assert(cutils.isfile(datafile))
      local T = Q.load_csv(datafile, M, O)
      T.val:eval()
      local srt_drg, srt_val = Q.drg_sort(T.drg, T.val, "asc")
      print("Test t3 completed for val/drg = ", val_qtype, drg_qtype)
      -- Q.print_csv({srt_val, srt_drg, T.chk_val, T.chk_drg}, { opfile = "_temp.csv", } )
       local n1, n2 = Q.sum(Q.vveq(srt_val, T.chk_val)):eval()
       assert(n1 == n2)
       --[[ Cannot do this because no guarantee on order of drag along 
       local n1, n2 = Q.sum(Q.vveq(srt_drg, T.chk_drg)):eval()
       assert(n1 == n2)
       --]]
       -- Hence, we go with a much weaker check which relies on the 
       -- way data has been constructed
       local x = Q.vconvert(srt_drg, "I4")
       local y = Q.vconvert(T.chk_drg, "I4")
       local x1 = Q.vsrem(x, 10)
       local y1 = Q.vsrem(y, 10)
       local n1, n2 = Q.sum(Q.vveq(x1, y1)):eval()
       -- Q.print_csv({x, y, x1, y1, })
       -- print(n1, n2)
       assert(n1 == n2)
    end
  end
  print("Test t3 completed")
end
-- TODO tests.t1()
-- TODO tests.t2()
tests.t3()
-- return tests
