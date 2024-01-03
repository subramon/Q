require 'Q/UTILS/lua/strict'
local Q         = require 'Q'
local qcfg	= require 'Q/UTILS/lua/qcfg'
local lgutils   = require 'liblgutils'
local cVector   = require 'libvctr'

local tests = {}

tests.t1 = function(sorted, optargs)
  local pre = lgutils.mem_used()
  local nC = 128 
  local len = (nC * 2) + 1

  local x = Q.seq( {start = len, by = -1, qtype = "I4", max_num_in_chunk = nC, len = len} ):set_name("x")
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", max_num_in_chunk = nC, len = len} ):set_name("y")
  if ( sorted ) then
    y:set_meta("sort_order", "asc")
  end
  local chk = Q.seq( {start = len-1, by = -1, qtype = "I4", max_num_in_chunk = nC, len = len} ):set_name("y")
  local z = Q.get_idx_by_val(x, y, optargs):set_name("z"):eval()
  -- Q.print_csv({x,y,z})
  if ( not optargs ) then 
    local nn_z = z:get_nulls()
    local r1 = Q.sum(nn_z)
    local n1, n2 = r1:eval()
    assert(n1 == n2)
    nn_z:delete()
    r1:delete()
  else
    assert(z:has_nulls() == false) 
  end

  local w = Q.vveq(z, chk)
  local r = Q.sum(w)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  --
  assert(cVector.check_all())
  x:delete()
  y:delete()
  z:delete()
  w:delete()
  r:delete()
  chk:delete()
  local post = lgutils.mem_used()
  assert(pre == post)
  print("Successfully completed t1")
end
-- return tests
tests.t1()
local sorted = false
local optargs = {all_x_in_y = true }
tests.t1(sorted, optargs)
sorted = true
optargs = {all_x_in_y = false }
tests.t1(sorted, nil)

