local plpath  = require 'pl.path'
local Q       = require 'Q'
local Scalar  = require 'libsclr'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local cVector = require 'libvctr'
local cutils  = require 'libcutils'
local lgutils = require 'liblgutils'
local qcfg    = require 'Q/UTILS/lua/qcfg'
-- configs 
local datafile = qcfg.q_src_root .. "/TESTS/SELECT/data/100K_1"
assert(plpath.isfile(datafile))
local n = assert(cutils.num_lines(datafile))
-- load big data set 
local M = {}
local O = { is_hdr = false } 
M[1] = { name = "tcin", qtype = "I4", has_nulls = false, memo_len = 1, }
M[2] = { name = "co_loc_ref_i",  qtype = "I2", has_nulls = false, }
M[3] = { name = "dist_loc_i",  qtype = "I2", has_nulls = false, memo_len = 1  }
M[4] = { name = "sls_unit_q",  qtype = "F4", has_nulls = true  }
M[5] = { name = "str_week",  qtype = "SC", has_nulls = false, width = 15, memo_len = 1, }
T1 = Q.load_csv(datafile, M, O)
for k, v in pairs(T1) do
  if ( k == "dist_loc_i" ) then assert(v:memo_len() == 1) end 
  if ( k == "sls_unit_q" ) then assert(v:memo_len() == -1) end 
end
--=================
T1.week_start_date = Q.SC_to_TM(T1.str_week, "%Y-%m-%d", 
  { out_qtype = "TM1" , name = "T1_wk_strt_dt", })
-- create I8 composite key, ck,  from T1.tcin and T1.dist_loc_i
T1.ck = Q.concat(T1.tcin, T1.dist_loc_i, { name = "T1_ck" })
--==================================================o
lVector.conjoin({T1.ck, T1.week_start_date})
T1.x = Q.is_prev(T1.ck, "neq", { default_val = true}):set_name("T1_x")
T1.id = Q.seq({len = n, start = 0, by = 1, qtype = "I8"}):set_name("T1.id")

-- START EXPERIMENTAL 
T1.x:eval()
T1.str_week:delete()
error("PREMATURE")
--  STOP EXPERIMENTAL 

T2 = {}
T2.lb = Q.where(T1.id, T1.x):set_name("T2_lb")
T2.ck = Q.where(T1.ck, T1.x):set_name("T2_ck")
lVector.conjoin({T2.ck, T2.lb})
-- create ub from lb 
T2.ub = Q.vshift(T2.lb, 1, Scalar.new(n, T2.lb:qtype())):set_name("T2_ub")
for i = 1, math.huge do 
  local n = T2.ub:get_chunk(i-1)
  if ( n == 0 ) then break end 
  T1.id:early_free()
end
assert(T1.ck:check())
assert(T1.id:check())
print("===== get_chunk error before this is okay =====")
assert(T2.lb:num_elements() == T2.ck:num_elements())
-- throw away stuff you don't need any more
print("START DELETED T1")
T1.id:delete() 
print("STOP  DELETED T1")
T1.x:delete()
print("STOP DELETED x")
T1.tcin:delete()
print("STOP DELETED tcin")
T1.str_week:delete()
print("STOP DELETED str_week")
T1.dist_loc_i:delete()
print("STOP DELETED dist_loc_i")
collectgarbage()
cVector.check_all()
local is_pr = true
if ( is_pr ) then
  local U = {} 
  local header = "ck,lb,ub"
  -- U[#U+1] = T2.tcin
  -- U[#U+1] = T2.dist_loc_i
  U[#U+1] = T2.ck
  U[#U+1] = T2.lb
  U[#U+1] = T2.ub
  Q.print_csv(U, { impl = "C", opfile = "_T2", header = header })
end
Q.save()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert(lgutils.mem_used() == 0)
assert(lgutils.dsk_used() > 0)
print("Quitting after PLP")
