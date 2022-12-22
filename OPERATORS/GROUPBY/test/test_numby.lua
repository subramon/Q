require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'

local tests = {}

tests.t0 = function()
  local nb = 2
  local col = Q.mk_col({0, 1, 0, 0, 1, 1, 1, 0, 1}, "I1")
  local rslt = Q.numby(col, nb):eval()
  assert(rslt:num_elements() == nb)
  assert(rslt:get1(0):to_num() == 4)
  assert(rslt:get1(1):to_num() == 5)
  print("Test t0 completed")
end

tests.t0_1 = function()
  -- negative test
  -- input column exceeds limit i.e value >= nb
  local nb = 2
  local col = Q.mk_col({0, 1, 0, 0, 1, 1, 1, 2, 1}, "I1")
  local res = Q.numby(col, nb)
  local status, res = pcall(res.eval, res)
  assert(status == false)
  print("Test t0_1 completed")
end

tests.t0_2 = function()
  -- input column has all 1's
  local nb = 2
  local col = Q.mk_col({1, 1, 1, 1, 1, 1, 1, 1, 1}, "I1")
  local res = Q.numby(col, nb):eval()
  assert(res:num_elements() == nb)
  assert(res:get1(0):to_num() == 0)
  assert(res:get1(1):to_num() == 9)
  print("Test t0_2 completed")
end

tests.t0_3 = function()
  -- input column has all 0's
  local nb = 2
  local col = Q.mk_col({0, 0, 0, 0, 0, 0, 0, 0, 0}, "I1")
  local res = Q.numby(col, nb):eval()
  assert(res:num_elements() == nb)
  assert(res:get1(0):to_num() == 9)
  assert(res:get1(1):to_num() == 0)
  print("Test t0_3 completed")
end

tests.t1 = function()
  local max_num_in_chunk = 64 
  local len = 2*max_num_in_chunk + 1
  local period = 3
  local a = Q.period( { len = len, start = 0, by = 1, period = period, 
     qtype = "I4", max_num_in_chunk = max_num_in_chunk, })

  local rslt = Q.numby(a, period)
  -- Q.print_csv(rslt)
  print("Test t1 completed")
end

tests.t2 = function()
  local max_num_in_chunk = 64 
  local len = 2*max_num_in_chunk + 1
  local lb = 0
  local ub = 4
  local range = ub - lb + 1
  local a = Q.rand({ len = len, lb = 0, ub = 4, qtype = "I4",
    max_num_in_chunk = max_num_in_chunk})
  Q.numby = require 'Q/OPERATORS/GROUPBY/lua/expander_numby'
  local rslt = Q.numby(a, range)
  assert(type(rslt) == "lVector")
  -- Q.print_csv(rslt)
  rslt:eval()
  for i = lb, ub do 
    local n1, n2 = Q.sum(Q.vseq(a, Scalar.new(i, "I4"))):eval()
    assert(n1 == rslt:get1(i))
  end
  print("Test t2 completed")
end


tests.t3 = function()
  -- Elements equal to chunk_size
  local period = 3
  local max_num_in_chunk = 64 
  local len = period*max_num_in_chunk
  local a = Q.period({ len = len, start = 0, by = 1, period = period, 
    qtype = "I4", max_num_in_chunk = max_num_in_chunk }):set_name("a")
  local rslt = Q.numby(a, period):set_name("rslt"):eval()
  assert(rslt:num_elements() == period)
  for i = 1, period do 
    assert(rslt:get1(i-1) == Scalar.new(len/period))
  end
  print("Test t3 completed")
end
-- return tests
tests.t0()
tests.t0_1()
tests.t0_2()
tests.t0_3()
tests.t1()
-- TODO tests.t2() Depends on rand which needs to be fixe
tests.t3()
