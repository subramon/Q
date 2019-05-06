local Q         = require 'Q'
local qconsts	= require 'Q/UTILS/lua/q_consts'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'
local Scalar    = require 'libsclr'

require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local n_src = 65

  local x = Q.seq( {start = 10, by = 1, qtype = "I4", len = n_src} )
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = n_src} ):eval()
  local idx = Q.seq( {start = 0, by = 1, qtype = "I4", len = n_src} ):eval()

  local z = Q.get_idx_by_val(x, y)
  local exp_z = Q.seq( {start = 9, by = 1, qtype = "I4", len = n_src} )
  -- Q.print_csv({x, z})
  -- some checking now
  local x1 = Q.vsgeq(idx, n_src)
  local x2 = Q.vsneq(z, -1)
  local x3 = Q.vvand(x1, x2)
  local n1, n2 = Q.sum(x3):eval()
  assert(n1:to_num() == 0)
  
  local x1 = Q.vslt(x, n_src)
  local x2 = Q.vveq(z, exp_z)
  local x3 = Q.vvand(x1, x2)
  local n1, n2 = Q.sum(x3):eval()
  -- Q.print_csv({x,y,z,exp_z,x1,x2,x3})
  local  exp_n = Q.sum(x1):eval()

  assert(n1 ==  exp_n)
  
  -- local n1, n2 = Q.sum(Q.vveq(z, exp_z)):eval()
  -- assert(n1:to_num() == x_length)
  -- assert(n2:to_num() == x_length)
  print("Successfully completed t1")
end
return tests
