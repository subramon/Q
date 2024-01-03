require 'Q/UTILS/lua/strict'
local Q         = require 'Q'
local qcfg	= require 'Q/UTILS/lua/qcfg'

local tests = {}

tests.t1 = function()
  local nC = 128 
  local len = (nC * 2) + 1

  local x = Q.seq( {start = len, by = -1, qtype = "I4", max_num_in_chunk = nC, len = len} ):set_name("x")
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", max_num_in_chunk = nC, len = len} ):set_name("y")
  local chk = Q.seq( {start = len-1, by = -1, qtype = "I4", max_num_in_chunk = nC, len = len} ):set_name("y")
  local z = Q.get_idx_by_val(x, y):set_name("z"):eval()
  local nn_z = z:get_nulls()
  local r1 = Q.sum(nn_z)
  local n1, n2 = r1:eval()
  assert(n1 == n2)

  -- Q.print_csv({x, y, z})
  local w = Q.vveq(z, chk)
  local r = Q.sum(w)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  --
  print("Successfully completed t1")
end
-- return tests
tests.t1()
