-- Create big table 
T1 = Q.load_csv(...)
for k, v in pairs(T1) do
  v:eval()
  break
end
-- create I8 composite key, ck,  from mdse_item_i and T.dist_loc_i
local T1.ck = Q.concat(T.mdse_item_i, T.dist_loc_i)

local T1.x = Q.is_prev(ck, "eq", { default_val = true})
local n = ck:num_elements()
local T1.idx = Q.idx(n)
local T2 = {}
T2.lb = Q.where(T1.idx, T1.x)
T2.ub = Q.shift(T1.lb, "up", { val = n})
T2.ck = Q.where(T1.ck, T1.x)

--== New data, call this T2
local ck2 = Q.concat(T2.mdse_item_i, T2.dist_loc_i)
local x2 = Q.a_in_b(ck1, ck2)
local lb2 = Q.where(lb, x2)
local ub2 = Q.where(ub, x2)

--== select relevant rows in T1 
local x = Q.expand_selection(lb2, ub2, n)
--== copy relevant rows from T1 to T3 
local T3 = {}
for k, v in pairs(T1) do 
  T3[k] = Q.where(T1.v.x) 
end
-- conjoin T3
-- materialize T3
for k, v in pairs(T3) do
  v:eval()
  break
end
-- dump it out
Q.print_csv(T3, { opfile = "xxx" } )

