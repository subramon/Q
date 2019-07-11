-- FUNCTIONAL
local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local diff = require 'Q/UTILS/lua/diff'
require 'Q/UTILS/lua/strict'
local plpath  = require 'pl.path'
local path_to_here = os.getenv("Q_SRC_ROOT") .. "/OPERATORS/F1F2OPF3/test/"
assert(plpath.isdir(path_to_here))

local tests = {}
tests.t1 = function()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
  local c3 = c1
  c1 = 10
  local c2 = Q.mk_col( {80,70,60,50,40,30,20,10}, "I8")
  local z = Q.vvadd(c3, c2):set_name("z")
  assert(z:get_name() == "z")
  local opt_args = { opfile = path_to_here .. "_out1.txt", filter = { lb = 1, ub = 4} }
  Q.print_csv(z, opt_args)
  local diff_status = diff(path_to_here .. "_out1.txt", path_to_here .. "out1.txt")
  assert(diff_status, "Input and Output csv file not matched")
  assert(Q.sum(Q.vvneq(z, Q.mk_col({81,72,63,54,45,36,27,18}, "I4"))):eval():to_num() == 0 )
  print("Test t1 succeeded")
end

tests.t2 = function()
  local input_table1 = {}
  local input_table2 = {}
  local expected_table = {}
  for i = 1, 65540 do
    input_table1[i] = i
    input_table2[i] = i * 10
    expected_table[i] = i + (i * 10)
  end
  local c1 = Q.mk_col(input_table1, "I4")
  local c2 = Q.mk_col(input_table2, "I4")
  local expected_col = Q.mk_col(expected_table, "I4")
  
  -- Perform vvadd
  local res = Q.vvadd(c1, c2)
  res:eval()
  
  -- Verification
  assert(Q.sum(Q.vvneq(res, expected_col)):eval():to_num() == 0)
  print("Test t2 succeeded")
end

return tests
