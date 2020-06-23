local Q = require 'Q'
local utils = require 'Q/UTILS/lua/utils'
local calc_benefit = require 'Q/ML/DT/lua/calc_benefit'
local make_dt = require 'Q/ML/DT/lua/make_dt'

local dt = {}
--[[
variable description
T	- table of m lVectors of length n, representing m features
g	- goal/target lVector of length n
alpha	- minimum benefit value of type number
n_T	- number of instances classified as negative (tails) in goal/target vector
n_H	- number of instances classified as positive (heads) in goal/target vector
best_k	- index of the feature f' in T for which maximum benefit is observed
best_split - feature point from f' where maximun benefit is observed
best_benefit - maximum benefit value
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

-- n_H1 is the number of heads in test data set at a given leaf
-- n_T_test is the number of tails in test data set at a given leaf
-- set n_H1 and n_T_test at each leaf node to zero
-- TODO P1 Where should this be called from?
local function init_leaf_heads_tails(
  D
  )
  if D.left or D.right then -- interior node
    if ( D.left ) then init_leaf_heads_tails(D.left) end 
    if ( D.right) then init_leaf_heads_tails(D.right) end
  else
    D.n_H_test = 0
    D.n_T_test = 0
  end
end

-- TODO P1: Does following work? Seems suspicious
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


-- Verify the decision tree
local function check_dt(
  D	
  )
  if not D then return true end

  if D.left or D.right then 
    -- TODO P2: Add check for max val feature 
    assert(type(D.feature) == "number")
    assert(D.feature >= 1)
    assert(type(D.threshold) == "number")
    assert(type(D.n_T) == "number")
    assert(type(D.n_H) == "number")
  end

  local chk_n_T = 0
  local chk_n_H = 0
  if D.left then 
    chk_n_T = chk_n_T + D.left.n_T
    chk_n_H = chk_n_H + D.left.n_H
  end
  if D.right then 
    chk_n_T = chk_n_T + D.right.n_T
    chk_n_H = chk_n_H + D.right.n_H
  end
  if ( D.left or D.right ) then -- this check is only for interior nodes
    if (D.n_T ~= chk_n_T) then
    end
    assert(D.n_T == chk_n_T)
    assert(D.n_H == chk_n_H)
  end
  check_dt(D.left)
  check_dt(D.right)
  return true
end

-- This function does the following:
-- It finds the leaf to which the instance, x, is assigned.
-- It updates n_H_test and n_T_test for that leaf
-- It returns n_H/n_T for that leaf
local function find_leaf_stats(
  D,    -- prepared decision tree
  x,    -- a table of numbers, indexed by feature
  g_val -- a number, representing goal value 
  )
  assert(type(D) == 'table')
  assert(type(x) == 'table')

  while true do
    if D.left == nil and D.right == nil then
      if g_val == 0 then -- tails
        D.n_T_test = D.n_T_test + 1
      else
        D.n_H_test = D.n_H_test + 1
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

dt.find_leaf_stats = find_leaf_stats
dt.check_dt = check_dt
dt.node_count = node_count
dt.init_leaf_heads_tails = init_leaf_heads_tails

return dt
