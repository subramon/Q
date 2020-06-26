local Q = require 'Q'
local cum_for_evan_dt = require 'Q/ML/DT/lua/cum_for_evan_dt'
local evan_dt_benefit = require 'Q/ML/DT/lua/evan_dt_benefit'

--[[
variable explanation
f	- feature vector (type lVector)
g	- target/goal feature (type lVector)
n_T     - number of instances classified as negative (tails) in goal/target vector
n_H     - number of instances classified as positive (heads) in goal/target vector
]]
local function calc_evan_benefit(
  f, -- feature
  g, -- goal j
  sum, -- sum/cnt = average of g
  cnt,
  min_to_split
  )
  -- START: Check parameters
  assert(type(sum) == "number")
  assert(type(cnt) == "number")
  assert(cnt > 0) 
  assert(type(g) == "lVector")
  assert(type(f) == "lVector")
  -- STOP: Check parameters

  local benefit = -math.huge
  local split_point = nil

  -- sort f in ascending order and g in drag along
  -- before sort, clone the vectors
  local f_clone = f:clone()
  local g_clone = g:clone()
  -- Q.print_csv({f_clone, g_clone}, { opfile = "_0.csv" } )
  assert(f_clone:qtype() == f:qtype())
  assert(g_clone:qtype() == g:qtype())
  Q.sort2(f_clone, g_clone, 'asc')
  -- Q.print_csv({f_clone, g_clone}, { opfile = "_1.csv" } )
  assert(f_clone:length() == cnt)
  assert(g_clone:length() == cnt)
  local V, S, C = cum_for_evan_dt(f_clone, g_clone)
  V:eval()
  assert(type(S) == "lVector")
  assert(type(S) == "lVector")
  assert(type(C) == "lVector")
  assert(S:length() == C:length())
  assert(S:qtype() == "F8")
  assert(C:qtype() == "I4")
  -- Q.print_csv({V, S, C})
  --=======================================
  local b = evan_dt_benefit(V, S, C, "", min_to_split, sum, cnt)
  assert(type(b) == "Reducer")
  local split_point, benefit = b:eval()
  
  f_clone:delete() -- explicit deletion
  g_clone:delete() -- explicit deletion
  V:delete() -- explicit deletion
  S:delete() -- explicit deletion
  C:delete() -- explicit deletion
  return benefit, split_point
end
return calc_evan_benefit
