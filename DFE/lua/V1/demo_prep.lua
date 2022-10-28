-- load data
local M = {}
M[1] = { name = "tcin", qtype = "I4", has_nulls = false, memo_len = 1, }
M[2] = { name = "co_loc_ref_i",  qtype = "I2", has_nulls = false, }
M[3] = { name = "dist_loc_i",  qtype = "I2", has_nulls = false, memo_len = 1  }
M[4] = { name = "sls_unit_q",  qtype = "F4", has_nulls = true  }
M[5] = { name = "str_week",  qtype = "SC", has_nulls = false, width = 15, memo_len = 1, }
T1 = Q.load_csv(datafile, M, { is_hdr = false} )
--=================
T1.week_start_date = Q.SC_to_TM(T1.str_week, "%Y-%m-%d", 
  { out_qtype = "TM1" , name = "T1_wk_strt_dt", })
T1.ck = Q.concat(T1.tcin, T1.dist_loc_i, { name = "T1_ck"})
lVector.conjoin({T1.ck, T1.week_start_date})
-- create I8 composite key, ck,  from T1.tcin and T1.dist_loc_i
T1.x = Q.is_prev(T1.ck, "neq", { default_val = true}):set_name("T1_x")
-- create a "primary key" T1.id
T1.id = Q.seq({len = n, start = 0, by = 1, qtype = "I8"}):set_name("T1.id")
--======================================
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
  T1.ck:early_free()
  T1.x:early_free()
end
-- throw away stuff you don't need any more
T1.id = nil; T1.x = nil; T1.ck = nil; T1.str_week = nil; 
T1.tcin = nil; T1.dist_loc_i = nil; 
collectgarbage()
