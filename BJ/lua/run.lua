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

local load1 = require 'load1'
local load2 = require 'load2'
--=======================================================
local T1 = load1() -- Load price_cds_dump.csv"
local T2 = load2() -- Load ils_cds_dump.csv"
-- mark rows for deletion in T2
local x1 = Q.vstrcmp(T2.item_location_status_c, "STORE")
local nT2 = T2:num_elements()
local mask = Q.const({val = 0, qtype = "I4", len = nT2})

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
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
print("run completed")
