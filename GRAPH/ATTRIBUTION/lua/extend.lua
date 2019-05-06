local Q = require 'Q'
local function extend(inT, y0)
  assert(type(inT) == "table")
  local xk = inT.x
  local yk = inT.y
  assert(type(xk) == "lVector")
  assert(type(yk) == "lVector")
  assert(type(y0) == "lVector")
  --========================================
  local z = Q.get_val_by_idx(yk, y0)
  local w = Q.vsgeq(z, 0)
  local T = {}
  T.x = Q.where(xk, w):eval()
  -- TODO Check what where returns when no elements to return
  if ( not T.x ) then return nil end 
  T.y = Q.where(z, w):eval()
  return T
end
return extend
