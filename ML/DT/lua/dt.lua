local Q = require 'Q'
local Scalar = require 'libsclr'
local utils = require 'Q/UTILS/lua/utils'
local calc_benefit = require 'Q/ML/DT/lua/calc_benefit'
local chk_params = require 'Q/ML/DT/lua/chk_params'

local dt = {}
--[[
variable description
T	- table of m lVectors of length n, representing m features
g	- goal/target lVector of length n
alpha	- minimum benefit value of type Scalar 
n_T	- number of instances classified as negative (tails) in goal/target vector
n_H	- number of instances classified as positive (heads) in goal/target vector
best_k	- index of the feature f' in T for which maximum benefit is observed
best_sf - feature point from f' where maximun benefit is observed
best_bf - maximum benefit value
bf	- benefit value for each feature f
sf	- feature point from f for which benefit value bf is observed

D	- Decision Tree Table having below fields
{ 
  n_T,		-- number of negative (tails) instances
  n_H,		-- number of positive (heads) instances
  feature,	-- feature index for the split
  feature_name  -- name of the feature selected as split point
  threshold,	-- feature point/value for the split
  left,		-- left decision tree
  right 	-- right decision tree
}
]]
local node_idx = 0 -- node indexing
local function prepare_dt(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
  alpha, -- Scalar, minimum benefit
  min_to_split,
  col_names,
  wt_prior
  )
  local m, n, ng = chk_params(T, g, alpha)
  local D = {}
  assert(ng == 2) --- LIMITATION FOR NOW 
  -- do not split a node if it has less than 10 samples 
  if ( not min_to_split ) then 
    min_to_split = 10 
  else
    assert(type(min_to_split) == "number")
  end
  assert(min_to_split >= 8)

  assert(type(col_names) == "table")

  local cnts = Q.numby(g, ng):eval()
  local n_T, n_H
  n_T = cnts:get1(0):to_num()
  n_H = cnts:get1(1):to_num()

  D.n_T = n_T
  D.n_H = n_H
  D.node_idx = node_idx
  node_idx = node_idx + 1

  -- stop expansion if following conditions met 
  if ( ( n_T == 0 ) or ( n_H == 0 ) ) then return D end
  if ( n_T + n_H < min_to_split )     then return D end 

  local best_bf --- best benefit
  local best_sf --- split point that yielded best benefit 
  local best_k  --- feature that yielded best benefit
  local del_f
  for k, f in pairs(T) do
    local maxval = Q.max(f):eval():to_num()
    local minval = Q.min(f):eval():to_num()
    if (maxval > minval) then
      local bf, sf = calc_benefit(f, g, n_T, n_H, wt_prior)
      if ( best_bf == nil ) or ( bf > best_bf ) then
        best_bf = bf
        best_sf = sf
        best_k = k
      end
    else
      -- This feature is not of any importance as it has similar values
      del_f = k
    end
  end
  error("premature")
  -- delete feature which is not important
  -- TODO: facing some weird behavior if I delete feature so commenting for now
  --[[
  if del_f then
    table.remove(T, del_f)
  end
  ]]
  -- print("Max benefit and respecitve feature is ")
  -- print(best_bf .. "\t" .. best_sf .. "\t" .. best_k)
  local l_alpha = alpha:to_num()
  if ( best_bf > l_alpha ) then 
    local x = Q.vsleq(T[best_k], best_sf):eval()
    local T_L = {}
    local T_R = {}
    D.feature   = best_k
    D.feature_name = col_names[best_k]
    D.threshold = best_sf
    D.benefit   = best_bf
    for k, f in pairs(T) do 
      T_L[k] = Q.where(f, x):eval()
    end
    g_L = Q.where(g, x):eval()
    D.left  = prepare_dt(T_L, g_L, alpha, min_to_split, col_names, wt_prior)
    for k, f in pairs(T) do
      T_R[k] = Q.where(f, Q.vnot(x)):eval()
    end
    g_R = Q.where(g, Q.vnot(x)):eval()
    D.right = prepare_dt(T_R, g_R, alpha, min_to_split, col_names, wt_prior)
  end
  return D
end


-- n_H1 is the number of heads in test data set at a given leaf
-- n_T1 is the number of tails in test data set at a given leaf
-- set n_H1 and n_T1 at each leaf node to zero
local function preprocess_dt(
  D      -- prepared decision tree
  )
  if D.left and D.right then
    preprocess_dt(D.left, col_names)
    preprocess_dt(D.right, col_names)
  else
    D.n_H1 = 0
    D.n_T1 = 0
  end
end


local function make_dt(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
  alpha, -- Scalar, minimum benefit
  min_to_split,
  col_names,
  wt_prior
)
  -- create D
  local tree = prepare_dt(T, g, alpha, min_to_split, col_names, wt_prior)

  -- preprocess DT
  --  1. initializes n_H1 and n_T1 to zero at leaves
  preprocess_dt(tree)

  return tree
end


local function node_count(
  D
  )
  local n_count = 1
  if D.left then
    n_count = n_count + node_count(D.left)
  end
  if D.right then
    n_count = n_count + node_count(D.right)
  end
  return n_count
end


local function check_dt(
  D	-- prepared decision tree
  )
  -- Verify the decision tree
  local status = true
  if not D then
    return status
  end

  -- either both left and right are defined or neither
  if D.left then assert(D.right) end
  if D.right then assert(D.left) end

  if D.left == nil and D.right == nil then
    assert(D.feature == nil)
    assert(D.threshold == nil)
    assert(D.n_T ~= nil)
    assert(D.n_H ~= nil)
  end

  if D.left and D.right then
    assert(D.n_T == D.left.n_T + D.right.n_T)
    assert(D.n_H == D.left.n_H + D.right.n_H)
  end

  -- TODO: Add more checks

  check_dt(D.left)
  check_dt(D.right)
end


-- This function does the following:
-- It finds the leaf to which the instance, x, is assigned.
-- It updates n_H1 and n_T1 for that leaf
-- It returns n_H/n_T for that leaf
local function predict(
  D,    -- prepared decision tree
  x,    -- a table of numbers, indexed by feature
  g_val -- a number, representing goal value 
  )
  assert(type(D) == 'table')
  assert(type(x) == 'table')

  while true do
    if D.left == nil and D.right == nil then
      if g_val == 0 then -- tails
        D.n_T1 = D.n_T1 + 1
      else
        D.n_H1 = D.n_H1 + 1
      end
      return D.n_H, D.n_T
    else
      local val = x[D.feature]
      if val > D.threshold then
        --print("Right Subtree")
        D = D.right
      else
        --print("Left Subtree")
        D = D.left
      end
    end
  end
end


dt.make_dt = make_dt
dt.predict = predict
dt.check_dt = check_dt
dt.node_count = node_count
dt.preprocess_dt = preprocess_dt

return dt
