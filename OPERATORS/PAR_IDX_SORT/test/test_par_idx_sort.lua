require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local lgutils = require 'liblgutils'
local cVector = require 'libvctr'

local tests = {}
tests.t1 = function()
  collectgarbage()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  local O = { is_hdr = false}
  local M = {}
  M[#M+1] = { name = "alt_val", qtype = "UI8", has_nulls = false, }
  M[#M+1] = { name = "val", qtype = "F8", has_nulls = false, }
  M[#M+1] = { name = "chk_srt_idx", qtype = "I4", has_nulls = false, }
  local Tx = Q.load_csv("./val.csv", M, O)
  Tx.val:eval()
  local nx = Tx.val:num_elements()
  local idx = Q.seq({start = 0, by = 1, qtype = "I4", len = nx})
  idx:eval()
  local M = {}
  M[#M+1] = { name = "cnt", qtype = "I8", has_nulls = false, }
  local Tc = Q.load_csv("./cnt.csv", M, O)
  Tc.cnt:eval()
  local srt_idx, y = Q.par_idx_sort(idx, Tx.val, Tc.cnt)

  assert(type(y) == "lVector")
  assert(y:qtype() == Tx.val:qtype())
  assert(y:is_eov())
  assert(y:has_nulls() == false)
  assert(y:get_meta("sort_order") == "asc")

  assert(type(srt_idx) == "lVector")
  assert(srt_idx:qtype() == idx:qtype())
  assert(srt_idx:is_eov())
  assert(srt_idx:has_nulls() == false)

  local len = Tx.val:num_elements()
  local r = Q.min(Tx.val)
  local n1, n2 = r:eval()
  r:delete()
  local minx = n1:to_num()
  local chk_y = Q.seq({start = minx, by = 1, 
    len = Tx.val:num_elements(), qtype = Tx.val:qtype()})
  local tmp = Q.vveq(y, chk_y)
  local r = Q.sum(tmp)
  local n1, n2 = r:eval()
  -- 
  local p = Q.is_prev(y, "leq", { default_val = true}):eval()
  local r = Q.sum(p)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  p:delete(); r:delete()

  -- 
  local p = Q.is_prev(chk_y, "leq", { default_val = true})
  local r = Q.sum(p)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  p:delete(); r:delete()

  -- check srt_idx
  local p = Q.vveq(srt_idx, Tx.chk_srt_idx)
  local r = Q.sum(p)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  p:delete(); r:delete()

  -- cleanup
  for k, v in pairs(Tx) do v:delete() end 
  for k, v in pairs(Tc) do v:delete() end 
  y:delete()
  chk_y:delete()
  tmp:delete()
  r:delete()
  local post = lgutils.mem_used()
  -- TODO Check srt_idx 
  -- TODO assert(pre == post) print(pre, post)
  collectgarbage("restart")

  print("Test par idx sort 1 completed successfully")
end
tests.t2 = function()
  collectgarbage()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  local O = { is_hdr = false}
  local M = {}
  -- load data 
  M[#M+1] = { name = "alt_val", qtype = "UI8", has_nulls = false, }
  M[#M+1] = { name = "val", qtype = "F8", has_nulls = false, }
  M[#M+1] = { name = "chk_srt_idx", qtype = "I4", has_nulls = false, }
  local Tx = Q.load_csv("./val.csv", M, O)
  Tx.alt_val:eval()
  -- load counts
  local M = {}
  M[#M+1] = { name = "cnt", qtype = "I8", has_nulls = false, }
  local Tc = Q.load_csv("./cnt.csv", M, O)
  Tc.cnt:eval()

  local srt_alt_val, y = Q.par_idx_sort(Tx.alt_val, Tx.val, Tc.cnt)

  assert(y:is_eov())
  assert(y:has_nulls() == false)
  assert(y:get_meta("sort_order") == "asc")

  assert(type(srt_alt_val) == "lVector")
  assert(srt_alt_val:qtype() == Tx.alt_val:qtype())
  assert(srt_alt_val:is_eov())
  assert(srt_alt_val:has_nulls() == false)

  Q.print_csv({y, srt_alt_val})
  -- TODO Check srt_alt_val

  -- cleanup
  for k, v in pairs(Tx) do v:delete() end 
  for k, v in pairs(Tc) do v:delete() end 
  local post = lgutils.mem_used()
  assert(pre == post) 
  collectgarbage("restart")

  print("Test par idx sort 2 completed successfully")
end
-- return tests
-- tests.t1()
tests.t2()

