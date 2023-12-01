local cutils = require 'libcutils'
local plutils= require 'pl.utils'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local ffi     = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local KeyCounter = require 'Q/RUNTIME/CNTR/lua/KeyCounter'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local lgutils  = require 'liblgutils'

local is_debug = true 
local load1 = require 'load1'
local load2 = require 'load2'
local sort_tcin_loc_del = require 'sort_tcin_loc_del'

--=======================================================
local T1 = load1() -- Load price_cds_dump.csv"
local T2 = load2() -- Load ils_cds_dump.csv"
-- mark rows for deletion in T2
local c1 = Q.vstrcmp(T2.item_location_status_c, "M")
local c2 = Q.vstrcmp(T2.item_location_status_c, "S")
local c3 = Q.vstrcmp(T2.item_location_status_c, "I")
local to_del = Q.vvor(c1, c2)
to_del = Q.vvor(to_del, c3)
local T2_tcin_loc, T2_to_del = sort_tcin_loc_del(
  T2.tcin, T2.location_id, to_del)
-- at this stage, we have (from T2)
-- (1) T2_tcin_loc which is a composite key sorted ascendiing with 
-- tcin in top 32 bits and location_id in bottom 32 bits
-- (2) T2_to_del which marks rows to be deleted
-- Now, do the same for T1
-- mark rows for deletion in T1
local x = Q.vstrcmp(T1.channel_n, "STORE")
local to_del = Q.vnot(x)
local T1_tcin_loc, T1_to_del = sort_tcin_loc_del(
  T1.tcin, T1.location_id, to_del)
--
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
local T2T1_to_del = X.val
-- del1 has all deletions except for time based ones
local del1 = Q.vvor(T1_to_del, T2T1_to_del)
-- create T2' based on rows that survive deletion
-- 2023-10-22 = 1697932800 -- Saturday 
-- 2023-10-29 = 1698537600 -- Saturday 
local stop_times = { 1697932800 1698537600, } 
assert(type(stop_times) == "table"); assert(#stop_times >= 1)
local maxt = stop_times[1]
for _, stop_time in ipairs(stop_times) do 
  if ( stop_tome > maxt ) then maxt = stop_time end 
end
maxt = maxt + (7*86400) -- set to a week ahead 
local x = T1.expiry_secs:get_nulls()
local y = Q.ifxthenyelsez(x, maxt, T1.expirys_secs)
T1.expiry_secs = y
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
  T1prime.tcin = Q.shift_right(T1prime.tcin_loc):convert("I4")
-- Join prices from T1prime to T4

T4.regular_avg = Q.vvdiv(T4.regular_numer, T4.regular_denom)
T4.current_avg = Q.vvdiv(T4.current_numer, T4.current_denom)
Q.print_csv({T4.tcin, T4.regular_avg, T4.current_avg}, 
  { opfile = "_x.csv"})
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
