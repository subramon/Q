
--[[
variable description
n_T_R   - number of negatives (tails) on right
n_H_R   - number of positives (heads) on right
n_T_L   - number of negatives (tails) on left
n_H_L   - number of positives (heads) on left
]]
-- TODO: export this function as Q's function --> Q.wtbnfit
local function wt_benefit(
  n_T_L,
  n_H_L,
  n_T_R,
  n_H_R,
  wt_prior -- weight of prior used to dampen differences
  )
  -- check parameters
  assert(n_T_L >= 0)
  assert(n_H_L >= 0)
  assert(n_T_R >= 0)
  assert(n_H_R >= 0)
  if ( wt_prior ) then
    assert(type(wt_prior) == "number")
    assert(wt_prior > 0)
  end

  -- determine total number on left and right
  local n_L = n_T_L + n_H_L -- total number on left
  local n_R = n_T_R + n_H_R -- total number on right
  local n_H = n_H_L + n_H_R -- total number of heads
  local n_T = n_T_L + n_T_R -- total number of tails
  local p_H = n_H / ( n_H + n_T)
  local p_T = n_T / ( n_H + n_T)

  local n = n_L + n_R -- total number

  -- determine left and right weightage
  local w_L = n_L / n -- weightage on left
  local w_R = n_R / n -- weightage on right

  local p_H_L -- prob of heads on left
  local p_H_R -- prob of heads on left
  local p_T_L -- prob of tails on left
  local p_T_R -- prob of tails on left
  if ( not wt_prior ) then 
    p_H_L = n_H_L / n_L 
    p_H_R = n_H_R / n_R 
    p_T_L = n_T_L / n_L 
    p_T_R = n_T_R / n_R 
  else
    local x_H = p_H * wt_prior;
    local x_T = p_T * wt_prior;
    p_H_L = (n_H_L + x_H) / (n_L + wt_prior)
    p_H_R = (n_H_R + x_H) / (n_R + wt_prior)
    p_T_L = (n_T_L + x_T) / (n_L + wt_prior)
    p_T_R = (n_T_R + x_T) / (n_R + wt_prior)
  end

  local o_H = n_T / n_H -- odds for heads 
  local o_T = n_H / n_T -- odds for tails 

  -- calculate benefit
  local b_H_L = ( o_H * p_H_L ) - ( 1 * p_T_L )
  local b_T_L = ( o_T * p_T_L ) - ( 1 * p_H_L )
  local b_H_R = ( o_H * p_H_R ) - ( 1 * p_T_R )
  local b_T_R = ( o_T * p_T_R ) - ( 1 * p_H_R )

  local b_L = math.max(b_H_L, b_T_L) -- benefit on left
  local b_R = math.max(b_H_R, b_T_R) -- benefit on right

  local b = ( w_L * b_L ) + ( w_R * b_R ) -- total benefit

  return b
end

return wt_benefit
