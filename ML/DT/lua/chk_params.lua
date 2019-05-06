local Q = require 'Q'
local Scalar = require 'libsclr'
local utils = require 'Q/UTILS/lua/utils'

local function chk_params(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
  alpha -- Scalar
  )
  -- START: Checking
  local nT = 0
  local n

  local sone = Scalar.new(1, "F4")
  --==============================================
  assert(type(T) == "table")
  -- Here, it's not sure that T is integer indexed table
  for k, v in pairs(T) do
    if ( not n ) then 
      n = v:length()
    else
      assert(n == v:length())
    end
    assert(type(v) == "lVector")
    assert(v:fldtype() == "F4")
    nT = nT + 1
  end
  assert(utils.table_length(T) == nT)
  --=====================================
  assert(type(alpha) == "Scalar")
  assert(alpha:to_num() > 0)
  --=====================================
  assert(g:length() == n, tostring(g:length()) .. ", " .. tostring(n))
  assert(g:fldtype() == "I4")
  -- LIMITATION: currently assuming g values to be 0 and 1
  local maxval = Q.max(g):eval():to_num()
  local minval = Q.min(g):eval():to_num()
  assert(minval >= 0)
  assert(maxval <= 1)
  local ng = 2
  
  return nT, n, ng
end

return chk_params
