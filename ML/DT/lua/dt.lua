local Q = require 'Q'
local Scalar = require 'libsclr'
local utils = require 'Q/UTILS/lua/utils'
local calc_benefit = require 'Q/ML/DT/lua/calc_benefit'
local make_dt = require 'Q/ML/DT/lua/make_dt'

local dt = {}
--[[
variable description
T	- table of m lVectors of length n, representing m features
g	- goal/target lVector of length n
alpha	- minimum benefit value of type Scalar 
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
-- n_T1 is the number of tails in test data set at a given leaf
-- set n_H1 and n_T1 at each leaf node to zero
-- TODO P1 Where should this be called from?
local function init_leaf_heads_tails(
  D
  )
  if D.left or D.right then -- interior node
    if ( D.left ) then preprocess_dt(D.left, col_names) end 
    if ( D.right) then preprocess_dt(D.right, col_names) end
  else
    D.n_H1 = 0
    D.n_T1 = 0
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
    if (D.n_T ~= D.left.n_T + D.right.n_T ) then 
      print("XXX", D.n_T, D.left.n_T, D.right.n_T)
    end
    if (D.n_H ~= D.left.n_H + D.right.n_H ) then 
      print("YYY", D.n_H, D.left.n_H, D.right.n_H)
    end
    -- assert(D.n_T == D.left.n_T + D.right.n_T)
    -- assert(D.n_H == D.left.n_H + D.right.n_H)
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

dt.predict = predict
dt.check_dt = check_dt
dt.node_count = node_count
dt.init_leaf_heads_tails = init_leaf_heads_tails

return dt
