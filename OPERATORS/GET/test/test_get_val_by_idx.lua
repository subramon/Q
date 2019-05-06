local Q         = require 'Q'
local qconsts	= require 'Q/UTILS/lua/q_consts'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'
local Scalar    = require 'libsclr'

require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  local x_length = 65
  local y_length = 80

  local x = Q.seq( {start = 1, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 2, by = 2, qtype = "I4", len = y_length} )
  local exp_z = Q.seq( {start = 4, by = 2, qtype = "I4", len = x_length} )
  y:eval()

  local z = Q.get_val_by_idx(x, y)
  -- Q.print_csv({x, z, exp_z})
  local n1, n2 = Q.sum(Q.vveq(z, exp_z)):eval()
  assert(n1:to_num() == x_length)
  assert(n2:to_num() == x_length)
  print("Successfully completed t1")
end
tests.t2 = function()
  local x_length = 65
  local y_length = 30

  local x = Q.seq( {start = 0, by = 1, qtype = "I4", len = x_length} )
  local y = Q.seq( {start = 2, by = 2, qtype = "I4", len = y_length} )
  y:eval()

  local null_val = Scalar.new(1000, "I4")
  local z = Q.get_val_by_idx(x, y, { null_val = null_val})
  -- TODO Write invariant for test Q.print_csv({x, z})
  print("Successfully completed t2")
end

-- Positive Test-case: checking for num_elements > chunk_size
tests.t3 = function()
  local x_length = qconsts.chunk_size + 2
  local y_length = qconsts.chunk_size * 4

  local x = Q.seq( {start = 3, by = 3, qtype = "I4", len = x_length} ):eval()
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} ):eval()
  local z = Q.get_val_by_idx(x, y)
  z:eval()
  assert(z:length() == x:length())
  print("Successfully completed test t3")
end

-- Positive Test-case: checking for num_elements > chunk_size
-- passing opt_args null_val as type 'Scalar'
tests.t4 = function()
  local x_length = qconsts.chunk_size + 2
  local y_length = qconsts.chunk_size * 3

  local x = Q.seq( {start = 3, by = 3, qtype = "I4", len = x_length} ):eval()
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} ):eval()
  local null_value = Scalar.new(1000, "I4")
  local z = Q.get_val_by_idx(x, y, {null_val = null_value})
  z:eval()
  assert(z:length() == x:length())
  print("Successfully completed test t4")
end

-- Positive Test-case: checking for num_elements > chunk_size
-- passing opt_args null_val as type 'number'
tests.t5 = function()
  local x_length = qconsts.chunk_size + 2
  local y_length = qconsts.chunk_size * 3

  local x = Q.seq( {start = 3, by = 3, qtype = "I4", len = x_length} ):eval()
  local y = Q.seq( {start = 1, by = 1, qtype = "I4", len = y_length} ):eval()
  -- providing 1000 as 'number' to be returned as value in z
  -- where if y vector does not have value for x idx entry
  local null_value = 1000
  local z = Q.get_val_by_idx(x, y)
  z:eval()
  assert(z:length() == x:length())
  print("Successfully completed test t5")
end

-- sample testcase for Q.get_val_by_idx() operator
tests.t6 = function()
  local x_length = 2
  local y_length = 5

  local x_idx_vec = Q.mk_col({1,3}, "I1")
  local y_val_vec = Q.mk_col({1,2,3,4,5}, "I1")
  -- indexing of get_val_by_idx starts from zero
  -- following will return idx(x_idx_vec) 1st and 3rd element of value vector(y_val_vec)
  local z = Q.get_val_by_idx(x_idx_vec, y_val_vec)
  z:eval()
  assert(z:length() == x_idx_vec:length())
  Q.print_csv(z)
  print("Successfully completed test t5")
end

return tests
