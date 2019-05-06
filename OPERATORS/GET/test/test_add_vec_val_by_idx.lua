local Q         = require 'Q'
local qconsts	= require 'Q/UTILS/lua/q_consts'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'
local Scalar    = require 'libsclr'

require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local n_idx = 65
  local n_val = n_idx

  local idx = Q.seq( {start = 0, by = 1, qtype = "I4", len = n_idx} )
  local src = Q.seq( {start = 0, by = 2, qtype = "I4", len = n_idx} )
  local dst = Q.const( {val = 100,  qtype = "I4", len = n_val} )
  local exp_dst = Q.seq( {start = 100, by = 2, qtype = "I4", len = n_idx} )
  dst:eval()

  Q.add_vec_val_by_idx(idx, src, dst)
  -- Q.print_csv({idx, src, dst})

  local n1, n2 = Q.sum(Q.vveq(dst, exp_dst)):eval()
  assert(n1 == n2)
  print("Successfully completed t1")
end
tests.t2 = function()
  local n_idx = 65
  local n_val = n_idx

  local idx = Q.seq( {start = n_idx, by = 1, qtype = "I4", len = n_idx} )
  local src = Q.seq( {start = 0, by = 2, qtype = "I4", len = n_idx} )
  local dst = Q.const( {val = 100,  qtype = "I4", len = n_val} )
  dst:eval()

  Q.add_vec_val_by_idx(idx, src, dst)
  -- Q.print_csv({idx, src, dst})

  local n1, n2 = Q.sum(Q.vveq(dst, dst)):eval()
  assert(n1 == n2)
  print("Successfully completed t2")
end
return tests
