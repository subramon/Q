local Q = require 'Q'
local calc_benefit = require 'Q/ML/DT/lua/calc_benefit'

local default_min_to_split = 8
local node_idx = 0 -- node indexing
local function make_dt(
  T, -- table of m lvectors of length n, indexed as 1, 2, 3, ...
  g, -- lVector of length n
  ng,
  alpha, -- number, minimum benefit
  min_to_split, -- number, do not split if leaf size smaller than this
  col_names,
  wt_prior,
  is_col_alive
  )
  local D = {}
  local cnts = Q.numby(g, ng):eval()
  local n_T, n_H
  n_T = cnts:get1(0):to_num()
  n_H = cnts:get1(1):to_num()


  D.n_T = n_T
  D.n_H = n_H
  D.node_idx = node_idx
  node_idx = node_idx + 1

  -- if is_col_alive not specified, assume all alive
  if ( not is_col_alive ) then
    is_col_alive = {}
    for k, v in pairs(T) do
      is_col_alive[k] = true
    end
  end
  -- stop expansion if following conditions met 
  if ( ( n_T == 0 ) or ( n_H == 0 ) ) then return D end
  if ( n_T + n_H < min_to_split )     then return D end 
  -- TODO P1 if ( n_T < min_to_split )     then return D end 
  -- TODO P1 if ( n_H < min_to_split )     then return D end 

  local best_benefit --- best benefit
  local best_split --- split point that yielded best benefit 
  local best_k  --- feature that yielded best benefit
  local del_f
  local my_is_col_alive = {} -- for the next call to make_dt()
  for k, f in pairs(T) do
    -- Default assumption: feature not useful for next call 
    my_is_col_alive[k] = false
    if ( is_col_alive[k] == true ) then
      local maxval = Q.max(f):eval():to_num()
      local minval = Q.min(f):eval():to_num()
      if ( maxval > minval ) then
        my_is_col_alive[k] = true
        -- print("Calculating benefit for ", col_names[k])
        local bf, sf = calc_benefit(f, g, ng, n_T, n_H, wt_prior)
        if ( type(bf) == "Scalar" ) then bf = bf:to_num() end
        if ( type(sf) == "Scalar" ) then sf = sf:to_num() end
        if ( best_benefit == nil ) or ( bf > best_benefit ) then
          best_benefit = bf
          best_split = sf
          best_k = k
        end
      end
    end
  end
  print("BEST", best_benefit, best_split, col_names[best_k])
  if ( best_benefit > alpha ) then 
    D.feature   = best_k
    D.feature_name = col_names[best_k]
    D.threshold = best_split
    D.benefit   = best_benefit
    --===================================
    local x_L = Q.vsleq(T[best_k], best_split):eval()
    local n_L, n = Q.sum(x_L):eval()
    n_L = n_L:to_num(); n = n:to_num()
    local n_R = n - n_L
    local lb = min_to_split
    local ub = n - min_to_split
    -- count num on left and split only if you have enough 
    if ( ( n_L >= lb )  and ( n_L <= ub ) ) then 
      local T_L = {}
      for k, f in pairs(T) do 
        T_L[k]  = Q.where(f, x_L):eval()
      end
      local g_L = Q.where(g, x_L):eval()
      D.left = make_dt(T_L, g_L, ng, alpha, min_to_split, col_names, 
        wt_prior, my_is_col_alive)
    end
    --===========================
    local x_R = Q.vnot(x_L):eval()
    -- count num on right and split only if you have enough 
    if ( ( n_R >= lb )  and ( n_R <= ub ) ) then 
      local T_R = {}
      for k, f in pairs(T) do
        T_R[k]  = Q.where(f, x_R):eval()
      end
      local g_R = Q.where(g, x_R):eval()
      D.right = make_dt(T_R, g_R, ng, alpha, min_to_split, col_names, 
        wt_prior, my_is_col_alive)
    end
    --===========================
  end
  return D
end
return make_dt
