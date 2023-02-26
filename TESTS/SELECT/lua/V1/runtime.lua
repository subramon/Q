local plpath  = require 'pl.path'
local Q       = require 'Q'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
--== Following happens at run time 

assert(type(arg) == "table")
local datafile = assert(arg[1])
assert(type(datafile) == "string")
datafile = qcfg.q_src_root .. "/DFE/data/" .. datafile 
local M = {}
local O = { is_hdr = true, }
M[1] = { name = "tcin", qtype = "I4", has_nulls = false }
M[2] = { name = "dist_loc_i",  qtype = "I2", has_nulls = false  }
local T4 = Q.load_csv(datafile, M, O)
T4.tcin:eval()
-- create composite key in T4
T4.ck = Q.concat(T4.tcin, T4.dist_loc_i)
-- get lb/ub from T2 to T4 using composite key 
T4.lb = Q.isby(T2.lb, T2.ck, T4.ck):eval():drop_nulls()
T4.ub = Q.isby(T2.ub, T2.ck, T4.ck):eval():drop_nulls()
T4.num = Q.vvsub(T4.ub, T4.lb):eval()
local is_pr = true
if ( is_pr ) then
  local U = {}
  local header = "tcin,dist_loc_i,ck,lb,ub,num"
  U[#U+1] = T4.tcin
  U[#U+1] = T4.dist_loc_i
  U[#U+1] = T4.ck
  U[#U+1] = T4.lb
  U[#U+1] = T4.ub
  U[#U+1] = T4.num
  Q.print_csv(U, { impl = "C", opfile = "_T4", header = header,  })
end
print("Created T4")
-- At this stage, T4 tells us what we need from T1 to put in T3

--== copy relevant rows from T1 to T3 
local xfer = { "co_loc_ref_i", "sls_unit_q", "week_start_date", }
local T3 = {}
for _, col in ipairs(xfer) do 
  assert(type(T1[col]) == "lVector", "Missing from T1 " .. col)
  print("Adding from T1 to T3 ", col)
  T3[col] = Q.select_ranges(T1[col], T4.lb, T4.ub)
end
T3.tcin       = Q.repeater(T4.tcin, T4.num)
T3.dist_loc_i = Q.repeater(T4.dist_loc_i, T4.num)

for k, v in pairs(T3) do 
  v:eval() 
  assert(v:is_eov())
  print(k, v:num_elements())
end
assert(cVector.check_all(true, true))

local tmp = { "tcin", "dist_loc_i", } 
for _, v in ipairs(xfer) do 
  tmp[#tmp+1] = v
end
xfer = tmp

-- dump it out
is_pr = true
if ( is_pr ) then
  local U = {}
  local header = table.concat(xfer, ",")
  local formats = {}
  for k, v in ipairs(xfer) do U[k] = T3[v] end
  for k, v in ipairs(xfer) do 
    if ( v == "week_start_date" ) then
      formats[#formats+1] = "%Y-%m-%d"
    else
      formats[#formats+1] = ""
    end
  end
  Q.print_csv(U, { impl = "C", opfile = "_T3", 
    header = header, formats = formats })
end

Q.save()
print("Completed runtime selection")
os.exit()
