local plpath  = require 'pl.path'
local Q       = require 'Q'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
--== Following happens at run time 

assert(type(arg) == "table")
local infile = assert(arg[1])
local outfile = assert(arg[2])
assert(type(infile) == "string")
assert(type(outfile) == "string")
assert(infile ~= outfile)
infile = qcfg.q_src_root .. "/DFE/data/" .. infile 
local M = {}
local O = { is_hdr = true, }
M[1] = { name = "tcin", qtype = "I4", has_nulls = false }
M[2] = { name = "dist_loc_i",  qtype = "I2", has_nulls = false  }
print("infile = ", infile)
local T4 = Q.load_csv(infile, M, O)
T4.tcin:eval()
-- create composite key in T4
T4.ck = Q.concat(T4.tcin, T4.dist_loc_i)
-- get lb/ub from T2 to T4 using composite key 
T4.lb = Q.isby(T2.lb, T2.ck, T4.ck):eval()
T4.ub = Q.isby(T2.ub, T2.ck, T4.ck):eval()
local is_pr = false
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
print("Created T4")
-- At this stage, T4 tells us what we need from T1 to put in T3

--== copy relevant rows from T1 to T3 
local xfer = { "tcin", "co_loc_ref_i", "dist_loc_i", 
  "sls_unit_q", "week_start_date", }
local T3 = {}
for _, col in ipairs(xfer) do 
   print("Adding from T1 to T3 ", col)
   T3[col] = Q.select_ranges(T1[col], T4.lb, T4.ub)
end
for k, v in pairs(T3) do 
  v:eval() 
  assert(v:is_eov())
end
assert(T3.sls_unit_q:has_nulls())
for k, v in pairs(T3) do assert(v:is_eov()) end
assert(cVector.check_all(true, true))

-- dump it out
is_pr = true
if ( is_pr ) then
  local U = {}
  local header = table.concat(xfer, ",")
  local formats = {}
  for k, v in ipairs(xfer) do 
    if ( v == "week_start_date" ) then
      formats[#formats+1] = "%Y-%m-%d"
    else
      formats[#formats+1] = ""
    end
  end
  for k, v in ipairs(xfer) do U[k] = T3[v] end
  Q.print_csv(U, { impl = "C", opfile = outfile, 
    -- header = header,  Taking this out for demo purposes
    formats= formats })
end

Q.save()
print("Completed runtime selection")
os.exit()
