-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local ffi = require 'Q/UTILS/lua/q_ffi'

local tests = {}
tests.t1 = function()
  local x = Q.mk_col({1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14}, 'I4')
  local quantiles, is_good = Q.approx_quantile(x, {num_quantiles = 2, err = 0.1 })
  Q.print_csv(quantiles)
  local sz, q, nn_q = quantiles:get_all()
  assert(sz == 2)
  assert(nn_q == nil)
  q = ffi.cast("int32_t *", q)
  assert(q[0] == 7)
  assert(q[1] == 14)
end

tests.t2 = function()
  local x = Q.seq({ len = 14, start = 1, by = 1, qtype = "I4"})
  local quantiles, is_good = Q.approx_quantile(x, {num_quantiles = 2, err = 0.1 })
  Q.print_csv(quantiles)
  local sz, q, nn_q = quantiles:get_all()
  assert(sz == 2)
  assert(nn_q == nil)
  q = ffi.cast("int32_t *", q)
  assert(q[0] == 7)
  assert(q[1] == 14)
end

return tests
