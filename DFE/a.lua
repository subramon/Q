local Q = require 'Q'
-- DONE Q.load_csv
-- DONE Test load_csv with null values
-- DONE Test load_csv with TM data type  (built SC_to_TM1)
-- DONE Test print_csv with TM data type 
-- DONE Test print_csv with null values
-- DONE Q.concat
-- DONE Q.is_prev
-- DONE Q.seq 
-- DONE Q.where 
-- TODO test conjoin
-- DONE Q.vshift
-- TODO Q.srt_join
-- DONE Q.select_ranges
-- DONE Q.print_csv
-- Create big table 
local T1 = Q.load_csv(...)
T1 = {}
for k, v in pairs(T1) do v:eval() break end
print("xxx")
-- create I8 composite key, ck,  from mdse_item_i and T.dist_loc_i
T1.ck = Q.concat(T.mdse_item_i, T.dist_loc_i)

T1.x = Q.is_prev(ck, "neq", { default_val = true})
local n = ck:num_elements()
T1.id = Q.seq({len = n, start = 0, by = 1, qtype = I8})
local T2 = {}
T2.lb = Q.where(T1.id, T1.x)
T2.ck = Q.where(T1.ck, T1.x)
-- conjoin T2.lb and T2.ck since they both depend on T1.x
T2.ub = Q.vshift(T1.lb, 1, Scalar.new(n, T1.lb:qtype()))
T2.ub:eval() -- materialize T2 with columns: {ck, lb, ub }

--== New data, call this T4
local T4 = Q.load_csv(...)
for k, v in pairs(T4) do v:eval() break end
-- create composite key in T4
T4.ck = Q.concat(T4.mdse_item_i, T4.dist_loc_i)
T4.lb = Q.srt_join(T2.lb, T2.ck, T4.ck)
T4.ub = Q.srt_join(T2.lb, T2.ck, T4.ck)

--== copy relevant rows from T1 to T3 
local T3 = {}
for k, v in pairs(T1) do 
  T3[k] = Q.where_ranges(T1.v, T4.lb, T4.ub)
end
-- conjoin T3
-- materialize T3
for k, v in pairs(T3) do v:eval() break end
-- dump it out
Q.print_csv(T3, { opfile = "xxx" } )

