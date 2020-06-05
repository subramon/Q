local Q = require 'Q'
local wt_benefit = require 'Q/ML/DT/lua/wt_benefit'

--[[
variable explanation
f	- feature vector (type lVector)
g	- target/goal feature (type lVector)
n_T     - number of instances classified as negative (tails) in goal/target vector
n_H     - number of instances classified as positive (heads) in goal/target vector
]]
local function calc_benefit(
  f,
  g,
  n_T,
  n_H,
  wt_prior
  )
  -- START: Check parameters
  assert(( type(n_T) == "Scalar") or ( type(n_T) == "number"))
  assert(( type(n_H) == "Scalar") or ( type(n_H) == "number"))
  assert(n_T > 0) -- changed check from >= 0 to > 0
  assert(n_H > 0) -- changed check from >= 0 to > 0
  assert(type(g) == "lVector")
  assert(type(f) == "lVector")
  -- STOP: Check parameters

  --[[
  TODO: steps to follow in benefit calculation
  1. count intervals --> f', h0, h1 = Q.cntinterval(f, g)
  2. calculate benefit --> b = Q.wtbnfit(h0, h1, n_T, n_H)
  3. get max benefit --> b', _, i = Q.max(b)
  return b', f[i]
  ]]

  local n = n_H + n_T
  local benefit = -math.huge
  local split_point = nil

  -- sort f in ascending order and g in drag along
  -- before sort, clone the vectors
  local f_clone = f:clone()
  local g_clone = g:clone()
  Q.sort2(f_clone, g_clone, 'asc')
  assert(f_clone:length() == n_T + n_H)
  assert(g_clone:length() == n_T + n_H)

  -- counters for goal values
  local C = {}
  C[0] = 0
  C[1] = 0

  local i = 0

  while i < n do
    local f_val = f_clone:get1(i):to_num()
    local g_val = g_clone:get1(i):to_num()
    C[g_val] = C[g_val] + 1
    i = i + 1
    while i < n  do
      local fi_val = f_clone:get1(i):to_num()
      local gi_val = g_clone:get1(i):to_num()
      if fi_val ~= f_val then
        break
      end
      C[gi_val] = C[gi_val] + 1
      i = i + 1
    end
    local f_val_benefit = wt_benefit(
      C[0], C[1], (n_T - C[0]), (n_H - C[1]), wt_prior)
    if f_val_benefit > benefit then
      benefit = f_val_benefit
      split_point = f_val
    end
  end
  assert(split_point) -- should be defined by now
  assert(benefit ~= -math.huge) -- should be defined by now
  f_clone:delete() -- explicit deletion
  g_clone:delete() -- explicit deletion
  return benefit, split_point
end
return calc_benefit
