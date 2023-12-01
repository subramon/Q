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

--=======================================================
local T1 = load1() -- Load T1 = price_cds_dump.csv
local T2 = load2() -- Load T2 = ils_cds_dump.csv
-- mark rows for deletion in T2
local c1 = Q.vstrcmp(T2.item_location_status_c, "M")
local c2 = Q.vstrcmp(T2.item_location_status_c, "S")
local c3 = Q.vstrcmp(T2.item_location_status_c, "I")
local to_del = Q.vvor(c1, c2)
to_del = Q.vvor(to_del, c3)
local T2_tcin_loc, T2_to_del = sort_tcin_loc_del(
  T2.tcin, T2.location_id, to_del, is_debug)
-- at this stage, we have (from T2)
-- (1) T2_tcin_loc which is a composite key sorted ascendiing with 
-- tcin in top 32 bits and location_id in bottom 32 bits
-- (2) T2_to_del which marks rows to be deleted
-- Now, do the same for T1
-- mark rows for deletion in T1
local to_del = Q.vnot(Q.vstrcmp(T1.channel_n, "STORE"))
local T1_tcin_loc, T1_to_del = sort_tcin_loc_del(
  T1.tcin, T1.location_id, to_del, is_debug)
-- at this stage, we have (from T1)
-- (1) T1_tcin_loc which is a composite key sorted ascendiing with 
-- tcin in top 32 bits and location_id in bottom 32 bits
-- (2) T1_to_del which marks rows to be deleted
--=========================================
-- create unique TCIN's
local T4 = {}
T4.tcin = Q.unique(T1.tcin):eval()
-- join T2_to_del from T2 into T1 
local X = Q.join(T2_to_del, T2_tcin_loc, T1_tcin_loc)
local T1_to_del_from_T2 = assert(X.val)
T1_to_del_from_T2:drop_nulls()
-- del1 has all deletions except for time based ones
local del1 = Q.vvor(T1_to_del, T1_to_del_from_T2)
-- create T2' based on rows that survive deletion
local maxt = 0
for _, stop_time in ipairs(stop_times) do 
  if ( stop_time > maxt ) then maxt = stop_time end 
end
maxt = maxt + (7*86400) -- set to a week ahead 
--=========================================
-- convert TM to time in seconds since epoch
T1.effective_secs = Q.tm_to_epoch(T1.effective_tm)
local x = T1.expiry_tm:get_nulls()
T1.expiry_secs    = Q.tm_to_epoch(T1.expiry_tm):eval()
T1.expiry_secs:set_nulls(x)
--=========================================
local x = T1.expiry_secs:get_nulls()
assert(type(x) == "BL")
T1.expiry_secs = Q.ifxthenyelsez(x, maxt, T1.expiry_secs)
T1.expiry_secs:eval()
error("PREMATURE")
--==================================================
for _, stop_time in ipairs(stop_times) do 
  -- find rows to discard based on stop_time 
  local x = Q.vslt(T1.expiry_secs, stop_time)
  local y = Q.vsgeq(T1.effective_secs, stop_time)
  local z = Q.vvor(x, y)
  local to_del = Q.vvor(z, del1)
  local keep = Q.vnot(to_del):eval()
  -- ==========================================
  local T1prime = {}
  T1prime.tcin_loc = Q.where(T1_tcin_loc, keep)
  T1prime.regular_retail_a = Q.where(T1.regular_retail_a, keep)
  T1prime.current_retail_a = Q.where(T1.current_retail_a, keep)
  T1prime.tcin = Q.shift_right(T1prime.tcin_loc, 32):convert("I4")
-- Join prices from T1prime to T4

--[[
  T4.regular_avg = Q.vvdiv(T4.regular_numer, T4.regular_denom)
  T4.current_avg = Q.vvdiv(T4.current_numer, T4.current_denom)
  Q.print_csv({T4.tcin, T4.regular_avg, T4.current_avg}, 
  { opfile = "_x.csv"})
  --]]
end

-- cleanup/checking/....
assert(cVector.check_all())
for k, v in pairs(T1) do v:delete() end; T = nil ; 
for k, v in pairs(T2) do v:delete() end; T = nil ; 
assert(cVector.check_all())
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
-- assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
print("run completed")
