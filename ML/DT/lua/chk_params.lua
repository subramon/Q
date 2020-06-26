local Q = require 'Q'
local Scalar = require 'libsclr'
local utils = require 'Q/UTILS/lua/utils'
local is_in = require 'Q/UTILS/lua/is_in'

local function chk_params(
  T, -- table of m lvectors of length n, indexed as 1, 2, 3...
  g, -- lVector of length n
  ng,
  is_goal_real
  )
  local ncols = 0
  local nrows
  --==============================================
  assert(type(T) == "table")
  for k, v in ipairs(T) do
    if ( not nrows ) then 
      nrows = v:length()
    else
      assert(nrows == v:length())
    end
    assert(type(v) == "lVector")
    assert(v:fldtype() == "F4")
    ncols = ncols + 1
  end
  assert(#T == ncols)
  --=====================================
  assert(g:length() == nrows)
  if ( not is_goal_real ) then 
    -- LIMITATION: currently assuming g values to be 0 and 1
    local maxval = Q.max(g):eval():to_num()
    local minval = Q.min(g):eval():to_num()
    assert(minval >= 0)
    assert(maxval < ng)
    assert(minval ~= maxval)
  end
  
  return ncols, nrows
end

return chk_params
