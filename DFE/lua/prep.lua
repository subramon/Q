local plpath  = require 'pl.path'
local Q       = require 'Q'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
-- configs 
local datafile = qcfg.q_src_root .. "/DFE/data/100K_1"
-- load big data set 
local M = {}
local O = { is_hdr = false } -- defualt memo_len == -1 
M[1] = { name = "tcin", qtype = "I4", has_nulls = false }
M[2] = { name = "co_loc_ref_i",  qtype = "I2", has_nulls = false  }
M[3] = { name = "dist_loc_i",  qtype = "I2", has_nulls = false  }
M[4] = { name = "sls_unit_q",  qtype = "F4", has_nulls = true  }
M[5] = { name = "week_start_date",  qtype = "SC", has_nulls = false, width = 15  }
assert(plpath.isfile(datafile))
T1 = Q.load_csv(datafile, M, O)
assert(T1.sls_unit_q:has_nulls() == true)
T1.sls_unit_q:eval()
cVector:check_all(true, true)
local is_pr = true
--==================================================o
-- create I8 composite key, ck,  from T1.tcin and T1.dist_loc_i
T1.ck = Q.concat(T1.tcin, T1.dist_loc_i)
T1.ck:eval(); 
print("Created T1.ck")
T1.x = Q.is_prev(T1.ck, "neq", { default_val = true})
print("Created T1.x")
T1.x:eval(); 

if ( is_pr ) then
  local U = {}
  local header = "tcin,dist_loc_i,ck,x"
  U[#U+1] = T1.tcin
  U[#U+1] = T1.dist_loc_i
  U[#U+1] = T1.ck
  U[#U+1] = T1.x
  Q.print_csv(U, { impl = "C", opfile = "_T1", header = header })
end

local n = T1.tcin:num_elements()
T1.id = Q.seq({len = n, start = 0, by = 1, qtype = "I8"})
print("Created T1.id")
T2 = {}
print("evaluating T2.lb")
T2.lb = Q.where(T1.id, T1.x):eval()
print("evaluating T2.ck")
T2.ck = Q.where(T1.ck, T1.x):eval()
print("#lb = ", T2.lb:num_elements())
print("#ck = ", T2.ck:num_elements())
T2.tcin = Q.where(T1.tcin, T1.x):eval() -- delete later 
T2.dist_loc_i = Q.where(T1.dist_loc_i, T1.x):eval() -- delete later 
assert(T2.lb:num_elements() == T2.ck:num_elements())
-- conjoin T2.lb and T2.ck since they both depend on T1.x
T2.ub = Q.vshift(T2.lb, 1, Scalar.new(n, T2.lb:qtype()))
T2.ub:eval() -- materialize T2 with columns: {ck, lb, ub }
print("#ub = ", T2.ub:num_elements())
if ( is_pr ) then
  local U = {}
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
--== Following happens at run time 
local datafile = qcfg.q_src_root .. "/DFE/data/run1.csv"
local M = {}
local O = { is_hdr = true, }
M[1] = { name = "tcin", qtype = "I4", memo_len = -1, has_nulls = false }
M[2] = { name = "dist_loc_i",  qtype = "I2", memo_len = -1, has_nulls = false  }
local T4 = Q.load_csv(datafile, M, O)
T4.tcin:eval()
-- create composite key in T4
T4.ck = Q.concat(T4.tcin, T4.dist_loc_i)
-- get lb/ub from T2 to T4 using composite key 
T4.lb = Q.isby(T2.lb, T2.ck, T4.ck):eval()
T4.ub = Q.isby(T2.ub, T2.ck, T4.ck):eval()
if ( is_pr ) then
  local U = {}
  local header = "tcin,dist_loc_i,ck,lb,ub"
  U[#U+1] = T4.tcin
  U[#U+1] = T4.dist_loc_i
  U[#U+1] = T4.ck
  U[#U+1] = T4.lb
  U[#U+1] = T4.ub

  Q.print_csv(U, { impl = "C", opfile = "_T4", header = header,  })
end
--== copy relevant rows from T1 to T3 
local T3 = {}
for k, v in pairs(T1) do 
   if ( ( k == "x" ) or ( k == "week_start_date" ) or ( k == "sls_unit_q" ) ) then 
     print("not yet implemented code to handle " .. k) -- TODO P1
   else
     print("Adding from T1 to T3 ", k)
     T3[k] = Q.select_ranges(v, T4.lb, T4.ub):eval()
   end
end
for k, v in pairs(T3) do v:eval() break end
-- dump it out
if ( is_pr ) then
  local U = {}
  local header = "id,tcin,co_loc_ref_i,dist_loc_i"
  U[#U+1] = T3.id
  U[#U+1] = T3.tcin
  U[#U+1] = T3.co_loc_ref_i
  U[#U+1] = T3.dist_loc_i
  Q.print_csv(U, { impl = "C", opfile = "_T3", header = header })
end

print("Completed prep")
