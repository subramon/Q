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
  local x = Q.seq( {start = 0, by = 2, qtype = "I4", len = n_idx} )
  local y = Q.const( {val = 100,  qtype = "I4", len = n_val} )
  y:eval()

  Q.set_sclr_val_by_idx(x, y, { sclr_val = -100 })
  Q.print_csv({idx, x, y})
  --[[
  local n1, n2 = Q.sum(Q.vveq(z, exp_z)):eval()
  assert(n1:to_num() == x_length)
  assert(n2:to_num() == x_length)
  --]]
  print("Successfully completed t1")
end

tests.t2 = function()
  local idx_len = qconsts.chunk_size + 2
  local x_len   = qconsts.chunk_size * 2
  -- odd indices(idx) to be set(by 10000 value) in x value vector
  local idx = Q.seq( {start = 1, by = 2, qtype = "I4", len = idx_len} )
  local x   = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_len} )
  local sclr_value = 10000
  Q.set_sclr_val_by_idx(idx, x, { sclr_val = sclr_value })
  -- validating the returned values
  for i = 1, idx_len do
    if i % 2 == 0 then
      assert(x:get_one(i-1):to_num() == sclr_value)
    else
      assert(x:get_one(i-1):to_num() == i)
    end
  end
  print("Successfully completed t2")
end

return tests
