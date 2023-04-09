-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local bit = require 'bit'
local lshift = bit.lshift
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local Scalar = require 'libsclr'
local lgutils = require 'liblgutils'

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
  local x = Q.mk_col(xvals, "I8", { name = "x", })
  local yvals = {}
  for i = 1, len do 
    yvals[i] = lshift(xvals[i], 1)
  end 
  local y = Q.mk_col(yvals, "I8", { name = "y", })
  local z = Q.shift_left(x, 1)
  assert(z:qtype() == x:qtype())
  local r1 = Q.sum(Q.vveq(y, z))
  local n1, n2 = r1:eval()
  r1:delete()

  assert(n1:to_num() == n2:to_num())

  local w = Q.shift_right(z, 1)
  local r2 = Q.sum(Q.vveq(x, w))
  local n1, n2 = r2:eval()
  assert(n1:to_num() == n2:to_num())
  r2:delete()

  print("test t1 passed")
  x:delete()
  y:delete()
  w:delete()
  z:delete()
end
-- return tests
tests.t1()
collectgarbage()
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
