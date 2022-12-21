-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local bit = require 'bit'
local lshift = bit.lshift
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local Scalar = require 'libsclr'
local qcfg   = require 'Q/UTILS/lua/qcfg'

local tests = {}
tests.t1 = function()
  local len = 65
  local xvals = {}
  local j = 0
  for i = 1, len do
    if ( j == 0 ) then 
      xvals[i] = j
    elseif ( j == 30 ) then
      j = 0
      xvals[i] = j
    else 
      xvals[i] = lshift(1,  j)
    end
    j = j + 1 
  end 
  local x = Q.mk_col(xvals, "I8")
  local yvals = {}
  for i = 1, len do 
    yvals[i] = lshift(xvals[i], 1)
  end 
  local y = Q.mk_col(yvals, "I8")
  local z = Q.shift_left(x, 1)
  local n1, n2 = Q.sum(Q.vveq(y, z)):eval()
  assert(n1:to_num() == n2:to_num())

  local w = Q.shift_right(z, 1)
  local n1, n2 = Q.sum(Q.vveq(x, w)):eval()
  assert(n1:to_num() == n2:to_num())

  -- Q.print_csv({x, y, z, w})
  print("test t1 passed")
end
-- return tests
tests.t1()
os.exit()
