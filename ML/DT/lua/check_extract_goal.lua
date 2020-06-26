local Q = require 'Q'
local calc_benefit = require 'Q/ML/DT/lua/calc_benefit'
local chk_params = require 'Q/ML/DT/lua/chk_params'
local is_in = require 'Q/UTILS/lua/is_in'

local function check_extract_goal(
  T, -- table of m lvectors of length n, indexed as 1, 2, 3, ...
  g, -- lVector of length n
  ng,
  is_goal_real,
  col_names
  )
  if ( is_goal_real ) then 
    assert(is_in(g:qtype(), { "I1", "I2", "I4", "I8", "F4", "F8" }))
  else
    assert(is_in(g:qtype(), { "I1", "I2", "I4", "I8" }))
  end
  local ncols, nrows = chk_params(T, g, ng, is_goal_real)
  local D = {}
  assert(type(col_names) == "table")
  for k1, v1 in ipairs(col_names) do
    assert(type(v1) == "string")
    for k2, v2 in ipairs(col_names) do
      if ( k1 ~= k2 ) then assert(v1~= v2) end 
    end
  end
  -- Current implementation assumes 2 values of goal as 0, 1
  if ( not is_goal_real ) then 
    local min_g, _ = Q.min(g):eval()
    assert(min_g:to_num() == 0)
    local max_g, _ = Q.max(g):eval()
    assert(max_g:to_num() == 1)
  end
  -- TODO P3: it is possible to have a train/test split that causes
  -- either the training or testing data set to all have one value 
  -- of the  goal. in that case, we should NOT assert. Instead, just
  -- warn the user and try another split 

  return true
end
return check_extract_goal
