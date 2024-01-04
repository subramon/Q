require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local lgutils = require 'liblgutils'

local tests = {}

tests.t0 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  local nb = 2
  local x = Q.mk_col({0, 1, 0, 0, 1, 1, 1, 0, 1}, "I1")
  local r = Q.numby(x, nb)
  assert(type(r) == "Reducer")
  local y = r:eval()
  assert(y:num_elements() == nb)
  assert(y:get1(0):to_num() == 4)
  assert(y:get1(1):to_num() == 5)
  x:delete()
  y:delete()
  y:delete()
  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
  print("Test t0 completed")
end

tests.t0_1 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  -- negative test
  -- input column exceeds limit i.e value >= nb
  local nb = 2
  local x = Q.mk_col({0, 1, 0, 0, 1, 1, 1, 2, 1}, "I1")
  local r = Q.numby(x, nb)
  assert(type(r) == "Reducer")
  local y = r:eval()
  assert(type(y) == "nil")
  x:delete()
  r:delete()
  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
  print("Test t0_1 completed")
end

tests.t0_2 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  -- input column has all 1's
  local nb = 2
  local x = Q.mk_col({1, 1, 1, 1, 1, 1, 1, 1, 1}, "I1")
  local r = Q.numby(x, nb)
  local y = r:eval()
  assert(y:num_elements() == nb)
  assert(y:get1(0):to_num() == 0)
  assert(y:get1(1):to_num() == 9)
  x:delete()
  r:delete()
  y:delete()
  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
  print("Test t0_2 completed")
end

tests.t0_3 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  -- input column has all 0's
  local nb = 2
  local x = Q.mk_col({0, 0, 0, 0, 0, 0, 0, 0, 0}, "I1")
  local r = Q.numby(x, nb)
  local y = r:eval()
  assert(y:num_elements() == nb)
  assert(y:get1(0):to_num() == 9)
  assert(y:get1(1):to_num() == 0)
  x:delete()
  r:delete()
  y:delete()
  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
  print("Test t0_3 completed")
end

tests.t1 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  local max_num_in_chunk = 64 
  local len = 2*max_num_in_chunk + 1
  local period = 3
  local a = Q.period( { len = len, start = 0, by = 1, period = period, 
     qtype = "I4", max_num_in_chunk = max_num_in_chunk, })

  local r = Q.numby(a, period)
  local y = r:eval()
  -- Q.print_csv(rslt)
  a:delete()
  r:delete()
  y:delete()
  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
  print("Test t1 completed")
end

tests.t2 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  local max_num_in_chunk = 64 
  local len = 2*max_num_in_chunk + 1
  local lb = 0
  local ub = 4
  local range = ub - lb + 1
  local a = Q.rand({ len = len, lb = 0, ub = 4, qtype = "I4",
    max_num_in_chunk = max_num_in_chunk})
  local rslt = Q.numby(a, range)
  assert(type(rslt) == "lVector")
  -- Q.print_csv(rslt)
  rslt:eval()
  for i = lb, ub do 
    local z =  Q.vseq(a, Scalar.new(i, "I4"))
    local w = Q.sum(z)
    local n1, n2 = w:eval()
    assert(n1 == rslt:get1(i))
    z:delete()
    w:delete()
  end
  a:delete()
  rslt:delete()
  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
  print("Test t2 completed")
end


tests.t3 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  -- Elements equal to chunk_size
  local period = 3
  local max_num_in_chunk = 128
  local len = period*max_num_in_chunk
  local a = Q.period({ len = len, start = 0, by = 1, period = period, 
    qtype = "I4", max_num_in_chunk = max_num_in_chunk }):set_name("a")
  local r = Q.numby(a, period)
  local y  = r:eval():set_name("y")
  assert(type(y) == "lVector")
  assert(y:num_elements() == period)
  for i = 1, period do 
    assert(y:get1(i-1) == Scalar.new(len/period))
  end
  a:delete()
  r:delete()
  y:delete()
  cVector.hogs("mem")
  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
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
