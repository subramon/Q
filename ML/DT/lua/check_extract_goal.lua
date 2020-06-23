local Q = require 'Q'
local calc_benefit = require 'Q/ML/DT/lua/calc_benefit'
local chk_params = require 'Q/ML/DT/lua/chk_params'

local function check_extract_goal(
  T, -- table of m lvectors of length n, indexed as 1, 2, 3, ...
  g, -- lVector of length n
  ng,
  col_names
  )
  local ncols, nrows = chk_params(T, g, ng)
  local D = {}
  assert(type(col_names) == "table")
  for k1, v1 in ipairs(col_names) do
    assert(type(v1) == "string")
    for k2, v2 in ipairs(col_names) do
      if ( k1 ~= k2 ) then assert(v1~= v2) end 
    end
  end
  -- Current implementation assumes 2 values of goal as 0, 1
  local min_g, _ = Q.min(g):eval()
  assert(min_g:to_num() == 0)
  local max_g, _ = Q.max(g):eval()
  assert(max_g:to_num() == 1)
  -- TODO P3: it is possible to have a train/test split that causes
  -- either the training or testing data set to all have one value 
  -- of the  goal. in that case, we should NOT assert. Instead, just
  -- warn the user and try another split 

  return ncols, nrows
end
return check_extract_goal
