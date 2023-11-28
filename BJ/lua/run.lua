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
-- convert TM1 to I4 time since epoch 
-- set null values to INT_MAX
-- eliminate rows based on date range 
-- join T2_to_del from T2 into T1 
-- create to_del based on all deletions
local to_del = Q.vvor(T1_to_del, T1_T2_to_del)
to_del = Q.vvor(to_del, T1_to_del_date)
local keep = Q.vnot(to_del):eval()
-- create T2' based on rows that survive deletion
local T2prime = {}
T2prime.tcin_loc = Q.where(T2_tcin_loc, keep)
T2prime.regular_retail_a = Q.where(T2.regular_retail_a, keep)
T2prime.current_retail_a = Q.where(T2.current_retail_a, keep)
T2prime.tcin = Q.shift_right(T2prime.tcin_loc):convert("I4")
-- Join prices from T2prime to T4

T4.regular_avg = Q.vvdiv(T4.regular_numer, T4.regular_denom)
T4.current_avg = Q.vvdiv(T4.current_numer, T4.current_denom)
Q.print_csv({T4.tcin, T4.regular_avg, T4.current_avg}, 
  { opfile = "_x.csv"})

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
