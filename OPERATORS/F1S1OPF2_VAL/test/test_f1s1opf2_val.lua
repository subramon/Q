local Q = require 'Q'
local Scalar = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'

local tests = {}

tests.t1 = function()
  -- vsgeq_val test
  local in_table = {1, 2, 3, 4, 5, 6, -1, -2, -1}
  local qtype = "I4"
  local col = Q.mk_col(in_table, qtype)
  local s = Scalar.new(-1, qtype)
  local res, idx = Q.vsgeq_val(col, s)
  Q.print_csv({res, idx})
  -- verification
  local exp_table = {1, 2, 3, 4, 5, 6, -1, -1}
  local exp_col = Q.mk_col(exp_table, qtype)
  local cmp_res = Q.vveq(res, exp_col)
  local sum, _ = Q.sum(cmp_res):eval()
  assert(sum:to_num() == exp_col:length())
  --assert(Q.sum(Q.vveq(res, exp_col)):eval():to_num() == exp_col:length())
  print("Successfully executed t1")
end

tests.t2 = function()
  -- vsgeq_val test, out vec should be nil
  local in_table = {1, 2, 3, 4, 5, 6, -1, -2, -3}
  local qtype = "I4"
  local col = Q.mk_col(in_table, qtype)
  local s = Scalar.new(8, qtype)
  local res = Q.vsgeq_val(col, s):eval()
  assert(res==nil)
  print("Successfully executed t2")
end

tests.t3 = function()
  -- vsgeq_val test, out vec should be same as input
  local in_table = {1, 2, 3, 4, 5, 6, -1, -2, -3}
  local qtype = "I4"
  local col = Q.mk_col(in_table, qtype)
  local s = Scalar.new(-3, qtype)
  local res = Q.vsgeq_val(col, s):eval()
  assert(Q.sum(Q.vvneq(res, col)):eval():to_num() == 0)
  print("Successfully executed t3")
end

tests.t4 = function()
  -- vsgeq_val test, more than chunk size values
  local len = qconsts.chunk_size + 500
  local col = Q.seq( {start = 1, by = 1, qtype = "I4", len = len} )
  local s = Scalar.new(qconsts.chunk_size+1, "I4")
  local res = Q.vsgeq_val(col, s):eval()
  print(res:length())
  assert(res:length() == 500)
  local exp_col = Q.seq( {start = qconsts.chunk_size+1, by = 1, qtype = "I4", len = 500} ):eval()
  assert(Q.sum(Q.vvneq(res, exp_col)):eval():to_num() == 0)
  print("Successfully executed t4")
end

return tests
