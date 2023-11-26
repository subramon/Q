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
--=======================================================
local T1 = load1() -- Load price_cds_dump.csv"
local T2 = load2() -- Load ils_cds_dump.csv"
-- mark rows for deletion in T2
local c1 = Q.vstrcmp(T2.item_location_status_c, "M")
local c2 = Q.vstrcmp(T2.item_location_status_c, "S")
local c3 = Q.vstrcmp(T2.item_location_status_c, "I")
local to_del = Q.vvor(c1, c2)
to_del = Q.vvor(to_del, c3)
local num_to_del = Q.sum(to_del):eval()
local x = Q.shift_left(T2.tcin, 1)
local y = Q.shift_left(T2.location_id, 1)
local z = Q.vvor(y, to_del)
--=================================================
local compkey = Q.concat(x, z)
local one = Scalar.new(1, compkey:qtype())
if ( is_debug ) then 
  assert(Q.sum(Q.vsand(compkey, one)):eval() == num_to_del)
end 
local T2_srt_compkey = Q.sort(compkey, "asc")
T2_srt_compkey = T2_srt_compkey:lma_to_chunks()
if ( is_debug ) then 
  assert(T2_srt_compkey:num_elements() == compkey:num_elements())
  assert(T2_srt_compkey:num_chunks()   == compkey:num_chunks())
  assert(Q.sum(Q.vsand(T2_srt_compkey, one)):eval() == num_to_del)
end 
local T2_to_del = Q.vconvert(Q.vsand(T2_srt_compkey, one), "I1")
-- at this stage, we have (from T2)
-- (1) T2_srt_compkey which is a composite key sorted ascendiing with 
-- tcin in top 32 bits and location_id in bottom 32 bits
-- (2) T2_to_del which marks rows to be deleted
-- Now, do the same for T1
--
-- at this stage, we have (from T1)
-- (1) srt_compkey which is a composite key sorted ascendiing with 
-- tcin in top 32 bits and location_id in bottom 32 bits
-- (2) del1 which marks rows to be deleted
local x = Q.vstrcmp(T1.channel_n, "STORE")
local T1_del1 = Q.vnot(x)
local T1_compkey = Q.concat(T1.tcin, T1.location_id)
local T1_srt_compkey = Q.sort(T1_compkey, "asc")
T1_srt_compkey = T1_srt_compkey:lma_to_chunks()
--=========================================
-- join to_del2 from T2 into T1 
-- create to_del 
-- TODO local to_del = Q.vvand(T1_to_del, T2_to_del)

--[[
local x1 = Q.vstrcmp(T.channel, "STORE")
  -- create composite pk
  local pk = Q.concat(T.tcin, T.location_id)
  assert(type(pk) == "lVector")
  assert(pk:qtype() == "I8")
  -- cleanup
  -- -]]
  -- cleanup
-- cleanup/checking/....
assert(cVector.check_all())
for k, v in pairs(T1) do v:delete() end; T = nil ; 
for k, v in pairs(T2) do v:delete() end; T = nil ; 
assert(cVector.check_all())
collectgarbage()
-- print("MEM", lgutils.mem_used())
-- print("DSK", lgutils.dsk_used())
-- assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
print("run completed")
