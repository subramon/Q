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


local load1 = require 'load1'
local load2 = require 'load2'
local sort_tcin_loc_del = require 'sort_tcin_loc_del'
local unique_tcins = require 'unique_tcins'

local is_debug = true 
collectgarbage("stop")
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
--=======================================================
local stop_times = require 'stop_times' -- INPUT 
assert(type(stop_times) == "table"); assert(#stop_times >= 1)
local maxt = 0
for _, stop_time in ipairs(stop_times) do 
  if ( stop_time > maxt ) then maxt = stop_time end 
end
maxt = maxt + (7*86400) -- set to a week ahead 
local T1 = load1() -- Load T1 = price_cds_dump.csv
local T2 = load2() -- Load T2 = ils_cds_dump.csv
-- mark rows for deletion in T2
local c1 = Q.vstrcmp(T2.item_location_status_c, "M")
local c2 = Q.vstrcmp(T2.item_location_status_c, "S")
local c3 = Q.vstrcmp(T2.item_location_status_c, "I")
local c4 = Q.vvor(c1, c2)
local to_del = Q.vvor(c3, c4)
local T2_tcin_loc, T2_to_del, _ = sort_tcin_loc_del(
  T2.tcin, T2.location_id, to_del, false, is_debug)
-- at this stage, we have (from T2)
-- (1) T2_tcin_loc which is a composite key sorted ascendiing with 
-- tcin in top 32 bits and location_id in bottom 32 bits
-- (2) T2_to_del which marks rows to be deleted
-- Now, do the same for T1
-- mark rows for deletion in T1
local to_keep = Q.vstrcmp(T1.channel_n, "STORE")
local to_del = Q.vnot(to_keep)
local T1_tcin_loc, T1_to_del, T1_srt_idx = sort_tcin_loc_del(
  T1.tcin, T1.location_id, to_del, true, is_debug)
assert(type(T1_srt_idx) == "lVector")
-- at this stage, we have (from T1)
-- (1) T1_tcin_loc which is a composite key sorted ascendiing with 
-- tcin in top 32 bits and location_id in bottom 32 bits
-- (2) T1_to_del which marks rows to be deleted
-- (3) T1_srt_idx used to permute other columns into the correct order
--]]
--=========================================
-- create unique TCIN's
local T4 = unique_tcins(T1.tcin) -- contains 1 column tcin 
-- join T2_to_del from T2 into T1 
local J1 = Q.join(T2_to_del, T2_tcin_loc, T1_tcin_loc)
local T1_to_del_from_T2 = assert(J1.val)
T1_to_del_from_T2:drop_nulls()
-- T1_del1 has all deletions except for time based ones
local T1_del1 = Q.vvor(T1_to_del, T1_to_del_from_T2)
-- create T2' based on rows that survive deletion
--=========================================
-- convert TM to time in seconds since epoch

T1.effective_tm:eval()
assert(T1.expiry_tm:is_eov())
T1.effective_secs = Q.tm_to_epoch(T1.effective_tm):set_name("T1_effective_secs"):eval()

T1.expiry_tm:eval()
local x = T1.expiry_tm:get_nulls()
assert(x:qtype() == "BL")
T1.expiry_secs    = Q.tm_to_epoch(T1.expiry_tm):set_name("T1_expiry_secs"):eval()
local y = Q.ifxthenyelsez(x, maxt, T1.expiry_secs):
  set_name("T1_expiry_secs"):eval()
x:delete() -- not null vector not needed any more 
T1.expiry_secs:delete(); 
T1.expiry_secs = y
--=========================================
-- Put expiry_secs and effective_secs in correct order
assert(T1_srt_idx:is_eov())
assert(T1.expiry_secs:num_elements() == T1_srt_idx:num_elements())
assert(T1.expiry_secs:max_num_in_chunk() == T1_srt_idx:max_num_in_chunk())
local x = Q.permute(T1.expiry_secs, T1_srt_idx, "to")
local y = x:lma_to_chunks(); x:delete(); 
T1.expiry_secs:delete(); T1.expiry_secs = y

assert(T1.effective_secs:num_elements() == T1_srt_idx:num_elements())
local x = Q.permute(T1.effective_secs, T1_srt_idx, "to")
local y = x:lma_to_chunks(); x:delete()
T1.effective_secs:delete(); T1.effective_secs = y

--=========================================

local final_T4 = {}; local final_empty = true
for i, stop_time in ipairs(stop_times) do 
  -- find rows to discard based on stop_time 
  local x = Q.vsgt(T1.expiry_secs, stop_time)
  local y = Q.vsleq(T1.effective_secs, stop_time)
  local z = Q.vvand(x, y)
  local notz = Q.vnot(z) --- to get rid off 
  local to_del = Q.vvor(notz, T1_del1)
  local keep = Q.vnot(to_del)
  local r = Q.sum(keep)
  local n1, n2 = r:eval()
  
  x:delete()
  y:delete()
  z:delete()
  notz:delete()
  to_del:delete()
  r:delete()

  local num_to_keep = n1:to_num()
  if ( num_to_keep == 0 ) then 
    keep:delete()
    print("Iteration ", i, "Nothing to keep from T1")
  else -- ELSE AAAA 
    print("Iteration ", i, "Keeping " .. num_to_keep .. " from T1")
    -- ==========================================
    T4.stop_time = Q.const({val = stop_time, 
      len = T4.tcin:num_elements(), qtype = "I4"}):eval()
    local T1prime = {}
    T1prime.tcin_loc         = Q.where(T1_tcin_loc, keep):eval()
    T1prime.regular_retail_a = Q.where(T1.regular_retail_a, keep):eval()
    T1prime.current_retail_a = Q.where(T1.current_retail_a, keep):eval()
    keep:delete()

    local tmp = Q.split(T1prime.tcin_loc, { out_qtypes = { "I4", "I4" }})
    T1prime.tcin = tmp[1]
    T1prime.location_id = tmp[2]
    T1prime.location_id:eval()

    Q.print_csv({
      T1prime.tcin, 
      T1prime.location_id, 
      T1prime.regular_retail_a, 
      T1prime.current_retail_a, 
    }, { opfile = "_T1prime_" .. stop_time .. ".csv" })

    -- Join prices from T1prime to T4
    for i, fld in ipairs({"regular", "current", }) do 
      infld = fld .. "_retail_a"
      local join_types = {"cnt", "sum", "min", "max", }
      local X = Q.join(T1prime[infld], T1prime.tcin, T4.tcin, join_types)
      X.sum:eval()
      -- X.sum:pr(); X.cnt:pr() 
      assert(X.sum:num_elements() == T4.tcin:num_elements())
      assert(X.cnt:is_eov())
      local x = X.sum:get_nulls()
      local denom = Q.ifxthenyelsez(x, X.cnt, 1) 
      local outfld = fld .. "_avg"
      local tmp = Q.vvdiv(X.sum, denom)
      T4[outfld] = Q.ifxthenyelsez(x, tmp, 0):eval()
      T4[outfld]:set_nulls(x)
      denom:delete()
      tmp:delete()
      T4.n_stores = X.cnt
      X.sum:delete()
      -- transfer min/max fields 
      X.max:drop_nulls(); outfld = fld .. "_max"; T4[outfld] = X.max
      X.min:drop_nulls(); outfld = fld .. "_min"; T4[outfld] = X.min
    end
    --================================================
    -- copy everything from T4 (except tcin) into final 
    for k, v in pairs(T4) do
      v:eval()
      local w = v:chunks_to_lma()
      assert(w:is_eov())
      if ( final_empty ) then 
        final_T4[k] = w
        final_T4[k]:set_name("final_" .. k)
      else
        assert(final_T4[k]:append(w)) 
        w:delete()
      end
      if ( k ~= "tcin" ) then 
        v:delete()
        T4[k] = nil
      end
    end
    if ( final_empty ) then final_empty = false end 
    --================================================
    for k, v in pairs(T1prime) do v:delete() end 
    for k, v in pairs(T4) do if ( k ~= "tcin" ) then v:delete() end end
  end -- ELSE AAA
end
local cols = { "tcin", "n_stores", "stop_time", 
  "current_avg", "current_min", "current_max", 
  "regular_avg", "regular_min", "regular_max", }


local col_names = {}
local Tpr = {}
for k, v in ipairs(cols) do 
  Tpr[#Tpr+1] = final_T4[v]
end
local header = table.concat(cols, ",")
Q.print_csv(Tpr, { opfile = "_final.csv", header = header })
print("All done, cleaning up")

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
  T1_srt_idx:delete()

  for k, v in pairs(J1) do v:delete() end 
  for k, v in pairs(T4) do v:delete() end; 
  -- for k, v in pairs(final_T4) do v:delete() end; 

  T1_to_del_from_T2:delete()
  T1_del1:delete()
  T1.effective_secs:delete()
  T1.expiry_secs:delete()

  print("Early return")
  return 0 
end
--==================================================
assert(cVector.check_all())
collectgarbage()
assert(cVector.check_all())
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
-- assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
print("run completed")
