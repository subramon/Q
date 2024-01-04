local Q         = require 'Q'
local get_ptr	= require 'Q/UTILS/lua/get_ptr'
local lgutils   = require 'liblgutils'

require 'Q/UTILS/lua/strict'

local tests = {}

tests.t1 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  local max_num_in_chunk = 64 
  local idx_len = max_num_in_chunk * 2 + 3  
  local val_len = max_num_in_chunk * 3 + 7 

  local idx = Q.seq( {start = 1, by = 1, qtype = "I4", 
    len = idx_len, max_num_in_chunk = max_num_in_chunk, } )
  local val = Q.seq( {start = 2, by = 2, qtype = "I4", 
    len = val_len, max_num_in_chunk = max_num_in_chunk, } )

  local chk_outval = Q.seq({start = 4, by = 2, qtype = "I4", 
    len = idx_len, max_num_in_chunk = max_num_in_chunk, } )

  local outval = Q.get_val_by_idx(val, idx)
  assert(type(outval) == "lVector")
  outval:eval()
  -- check that all values are defined
  assert(outval:has_nulls())
  local nn = outval:get_nulls()
  local r2 = Q.sum(nn)
  local n1, n2 = r2:eval()
  assert(n1 == n2) 
  assert(outval:has_nulls() == false)

  local w = Q.vveq(outval, chk_outval)
  local r = Q.sum(w)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  Q.print_csv({idx, outval, chk_outval}, {opfile = "_x"})
  -- cleanup
  idx:delete()
  val:delete()
  outval:delete()
  chk_outval:delete()
  w:delete()
  r:delete()
  nn:delete()
  r2:delete()
  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
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

-- return tests
tests.t1()
