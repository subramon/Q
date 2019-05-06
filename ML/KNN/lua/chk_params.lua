local Q = require 'Q'
local Scalar = require 'libsclr'
local utils = require 'Q/UTILS/lua/utils'

local chk_fns = {}

local function chk_test_sample(
  x -- table of length m
  )
  local nx = 0
  assert(type(x) == "table")
  for k, v in pairs(x) do
    assert(type(v) == "Scalar")
    assert(v:fldtype() == "F4")
    nx = nx + 1
  end
  assert(#x == nx)
  return true
end

local function chk_params(
  T, -- table of m lvectors of length n
  g, -- lVector of length n
  k  -- a number of scalar
  )
  -- START: Checking
  local nT = 0
  local n

  --==============================================
  assert(type(T) == "table")
  for k, v in pairs(T) do
    n = v:length()
    break
  end
  for k, v in pairs(T) do
    assert(type(v) == "lVector")
    assert(v:fldtype() == "F4", "ERROR = " .. v:fldtype())
    assert(n == v:length())
    nT = nT + 1
  end
  assert(utils.table_length(T) == nT)
  --=====================================
  assert(type(k) == "number" or type(k) == "Scalar")
  --=====================================
  assert(g:length() == n)
  assert(g:fldtype() == "I4")
  local minval, numval = Q.min(g):eval()
  assert(minval == Scalar.new(0, "I4"))
  local maxval, numval = Q.max(g):eval()
  local ng = maxval:to_num() - minval:to_num() + 1 -- number of values of goal attr
  assert(ng > 1)
  assert(ng <= 4) -- arbitary limit for now 
  --=====================================
  -- STOP : Checking
  return nT, n, ng
end

chk_fns.chk_params = chk_params
chk_fns.chk_test_sample = chk_test_sample

return chk_fns
