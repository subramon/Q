local plpath  = require 'pl.path'
local Q       = require 'Q'
local Scalar  = require 'libsclr'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local cVector = require 'libvctr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
-- configs 
local datafile = qcfg.q_src_root .. "/DFE/data/100K_1"
assert(plpath.isfile(datafile))
-- load big data set 
local M = {}
local O = { is_hdr = false } 
M[1] = { name = "tcin", qtype = "I4", has_nulls = false, memo_len = 1, }
M[2] = { name = "co_loc_ref_i",  qtype = "I2", has_nulls = false, memo_len = 1, }
M[3] = { name = "dist_loc_i",  qtype = "I2", has_nulls = false  }
M[4] = { name = "sls_unit_q",  qtype = "F4", has_nulls = true  }
M[5] = { name = "str_week",  qtype = "SC", has_nulls = false, width = 15, memo_len = 1, }
T1 = Q.load_csv(datafile, M, O)
--=================
T1.week_start_date = Q.SC_to_TM(T1.str_week, "%Y-%m-%d", 
  { out_qtype = "TM1" , name = "week_start_date", })
T1.ck = Q.concat(T1.tcin, T1.dist_loc_i, { name = "ck" }):set_name("T1.ck")
lVector.conjoin({T1.ck, T1.week_start_date})
--==================================================o
-- create I8 composite key, ck,  from T1.tcin and T1.dist_loc_i
T1.x = Q.is_prev(T1.ck, "neq", { default_val = true, memo_len = 1}):set_name("T1.x")
local n = 1048576 * 1048576 -- much bigger than will be used
T1.id = Q.seq({len = n, start = 0, by = 1, qtype = "I8", memo_len = 1, }):set_name("T1.id")

T2 = {}
T2.lb = Q.where(T1.id, T1.x)
T2.ck = Q.where(T1.ck, T1.x)
lVector.conjoin({T2.ck, T2.lb})
T2.ub = Q.vshift(T2.lb, 1, Scalar.new(n, T2.lb:qtype()))
T2.ub:eval()
assert(T2.lb:num_elements() == T2.ck:num_elements())
if ( is_pr ) then
  local U = {}
  local header = "tcin,dist_loc_i,ck,lb,ub"
  local header = "tcin,dist_loc_i,ck,lb,ub"
  U[#U+1] = T2.tcin
  U[#U+1] = T2.dist_loc_i
  U[#U+1] = T2.ck
  U[#U+1] = T2.lb
  U[#U+1] = T2.ub
  Q.print_csv(U, { impl = "C", opfile = "_T2", header = header })
end
Q.save()
print("Quitting after PLP")
os.exit()
