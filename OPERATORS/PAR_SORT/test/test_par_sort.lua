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
  M[#M+1] = { name = "val", qtype = "I8", has_nulls = false, }
  local Tx = Q.load_csv("./val.csv", M, O)
  Tx.val:eval()
  local M = {}
  M[#M+1] = { name = "cnt", qtype = "I8", has_nulls = false, }
  local Tc = Q.load_csv("./cnt.csv", M, O)
  Tc.cnt:eval()
  local y = Q.par_sort(Tx.val, Tc.cnt)
  assert(type(y) == "lVector")
  assert(y:qtype() == Tx.val:qtype())
  assert(y:is_eov())
  assert(y:has_nulls() == false)
  assert(y:get_meta("sort_order") == "asc")
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
  -- cleanup
  for k, v in pairs(Tx) do v:delete() end 
  for k, v in pairs(Tc) do v:delete() end 
  y:delete()
  chk_y:delete()
  tmp:delete()
  r:delete()
  local post = lgutils.mem_used()
  -- TODO assert(pre == post)
  collectgarbage("restart")

  print("Test par sort 1 completed successfully")
end
-- return tests
tests.t1()

