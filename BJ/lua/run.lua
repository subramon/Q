local cutils = require 'libcutils'
local plutils= require 'pl.utils'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local ffi     = require 'ffi'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local lgutils  = require 'liblgutils'

local is_debug = true 
local load1 = require 'load1'
local load2 = require 'load2'
local stop_times = require 'stop_times' -- INPUT 
assert(type(stop_times) == "table"); assert(#stop_times >= 1)
local sort_tcin_loc_del = require 'sort_tcin_loc_del'

collectgarbage("stop")
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
--=======================================================
local T1 = load1() -- Load T1 = price_cds_dump.csv
local T2 = load2() -- Load T2 = ils_cds_dump.csv
T1.tcin:eval() -- TODO DELETE 
T2.tcin:eval() -- TODO DELETE 
-- mark rows for deletion in T2
local c1 = Q.vstrcmp(T2.item_location_status_c, "M")
local c2 = Q.vstrcmp(T2.item_location_status_c, "S")
local c3 = Q.vstrcmp(T2.item_location_status_c, "I")
local c4 = Q.vvor(c1, c2)
local unsrt_T2_to_del = Q.vvor(c3, c4)
local T2_tcin_loc, T2_to_del = sort_tcin_loc_del(
  T2.tcin, T2.location_id, unsrt_T2_to_del, is_debug)
-- at this stage, we have (from T2)
-- (1) T2_tcin_loc which is a composite key sorted ascendiing with 
-- tcin in top 32 bits and location_id in bottom 32 bits
-- (2) T2_to_del which marks rows to be deleted
-- Now, do the same for T1
-- mark rows for deletion in T1
local T1_keep = Q.vstrcmp(T1.channel_n, "STORE")
local T1_unsrt_to_del = Q.vnot(T1_keep)
local T1_tcin_loc, T1_to_del = sort_tcin_loc_del(
  T1.tcin, T1.location_id, T1_unsrt_to_del, is_debug)
-- at this stage, we have (from T1)
-- (1) T1_tcin_loc which is a composite key sorted ascendiing with 
-- tcin in top 32 bits and location_id in bottom 32 bits
-- (2) T1_to_del which marks rows to be deleted
--=========================================
-- create unique TCIN's

local T4 = {}
local val, cnt = Q.unique(T1.tcin)
assert(type(val) == "lVector")
assert(type(cnt) == "lVector")
val:eval()
assert(cnt:num_elements() == val:num_elements())
T4.tcin = val; val = nil
T4.cnt  = cnt; cnt = nil
-- join T2_to_del from T2 into T1 
local J1 = Q.join(T2_to_del, T2_tcin_loc, T1_tcin_loc)
local T1_to_del_from_T2 = assert(J1.val)
T1_to_del_from_T2:drop_nulls()
-- T1_del1 has all deletions except for time based ones
local T1_del1 = Q.vvor(T1_to_del, T1_to_del_from_T2)
-- create T2' based on rows that survive deletion
local maxt = 0
for _, stop_time in ipairs(stop_times) do 
  if ( stop_time > maxt ) then maxt = stop_time end 
end
maxt = maxt + (7*86400) -- set to a week ahead 
--=========================================
-- convert TM to time in seconds since epoch

T1.effective_tm:eval()
assert(T1.expiry_tm:is_eov())
T1.effective_secs = Q.tm_to_epoch(T1.effective_tm):set_name("T1_effective_secs")
T1.expiry_tm:eval()
local x = T1.expiry_tm:get_nulls()
T1.expiry_secs    = Q.tm_to_epoch(T1.expiry_tm):eval()
T1.expiry_secs:set_nulls(x)
--=========================================
local x = T1.expiry_secs:get_nulls()
assert(x:qtype() == "BL")
local y = Q.ifxthenyelsez(x, maxt, T1.expiry_secs):
  set_name("T1_expiry_secs"):eval()
x:delete() -- not null vector not needed any more 
T1.expiry_secs:delete(); 
T1.expiry_secs = y


for i, stop_time in ipairs(stop_times) do 
  -- find rows to discard based on stop_time 
  local t = Q.const({val = stop_time, 
    len = T1.expiry_secs:num_elements(),
    qtype = T1.expiry_secs:qtype()}):eval() -- for debugging only
  local x = Q.vsgt(T1.expiry_secs, stop_time)
  local y = Q.vsleq(T1.effective_secs, stop_time)
  local z = Q.vvand(x, y)
  local notz = Q.vnot(z) --- to get rid off 
  local to_del = Q.vvor(notz, T1_del1)
  local keep = Q.vnot(to_del)
  local r = Q.sum(keep)
  local n1, n2 = r:eval()
  t:delete() 
  x:delete()
  y:delete()
  z:delete()
  notz:delete()
  to_del:delete()
  r:delete()
  local num_to_keep = n1:to_num()
  if ( num_to_keep == 0 ) then 
    print("Nothing to keep from T1")
  else -- ELSE AAAA 
    print(i, "Keeping " .. num_to_keep .. " from T1")
    -- ==========================================
    local T1prime = {}
    T1prime.tcin_loc = Q.where(T1_tcin_loc, keep):eval()
    T1prime.regular_retail_a = Q.where(T1.regular_retail_a, keep):eval()
    T1prime.current_retail_a = Q.where(T1.current_retail_a, keep):eval()
    local tmp = Q.shift_right(T1prime.tcin_loc, 32)
    T1prime.tcin = Q.vconvert(tmp, "I4"):eval()
    tmp:delete()
    Q.print_csv({
      T1prime.tcin_loc, 
      T1prime.regular_retail_a, 
      T1prime.current_retail_a, 
      T1prime.tcin, }, { opfile = "_T1prime.csv" })
    -- Join prices from T1prime to T 4
    for _, fld in ipairs({"regular", "current"}) do 
      infld = fld .. "_retail_a"
      local join_types = {"cnt", "sum"}
      local X = Q.join(T1prime[infld], T1prime.tcin, T4.tcin, join_types)
      X.sum:eval()
      X.cnt:pr()
      assert(X.sum:num_elements() == T4.tcin:num_elements())
      assert(X.cnt:is_eov())
      local x = X.sum:get_nulls()
      local denom = Q.ifxthenyelsez(x, X.cnt, 1) 
      outfld = fld .. "_avg"
      local tmp = Q.vvdiv(X.sum, denom)
      T4[outfld] = Q.ifxthenyelsez(x, tmp, 0):eval()
      T4[outfld]:set_nulls(x)
      T4[outfld]:pr()
      denom:delete()
      tmp:delete()
      for k, v in pairs(X) do v:delete() end 
    end
    -- get ready for printing 
    T4.stop_time = Q.const({val = stop_time, qtype = "I4",
      len = T4.tcin:num_elements()})
    local Tpr = {}
    local hdr = {}
    for k, v in pairs(T4) do 
      hdr[#hdr+1] = k
      Tpr[#Tpr+1] = v
    end
    hdr = table.concat(hdr,",")
    Q.print_csv(Tpr, { headers = hdr, opfile = "_T4.csv"})
    --================================================
    for k, v in pairs(T1prime) do v:delete() end 
    for k, v in pairs(T4) do v:delete() end 
  end -- ELSE AAA
  keep:delete()
end

if ( true ) then 
  for k, v in pairs(T1) do v:delete() end 
  for k, v in pairs(T2) do v:delete() end 
  for k, v in pairs(T4) do v:delete() end 
  c1:delete()
  c2:delete()
  c3:delete()
  c4:delete()
  T2_to_del:delete()
  T2_tcin_loc:delete()
  T1_tcin_loc:delete()
  T1_to_del:delete()
  T1_keep:delete()
  T1_unsrt_to_del:delete()
  for k, v in pairs(J1) do v:delete() end 
  T1_to_del_from_T2:delete()
  T1_del1:delete()

  T1.effective_secs:delete()
  T1.expiry_secs:delete()
  print("MEM", lgutils.mem_used())
  assert(lgutils.mem_used() == 0)
  print("DSK", lgutils.dsk_used())
  assert(lgutils.dsk_used() == 0)
  collectgarbage("restart")
  print("Early return")
  return 0 
end
--==================================================

-- cleanup/checking/....
assert(cVector.check_all())
for k, v in pairs(T1) do v:delete() end; 
for k, v in pairs(T2) do v:delete() end; 
for k, v in pairs(T4) do v:delete() end; 
for k, v in pairs(J1) do v:delete() end; 
T1.effective_secs:delete()
T1.expiry_secs:delete()
collectgarbage()
assert(cVector.check_all())
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
-- assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
print("run completed")
