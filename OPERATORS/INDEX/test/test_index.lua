--functional test
local Q = require 'Q'
local utils = require 'Q/UTILS/lua/utils'
local qconsts = require 'Q/UTILS/lua/q_consts'
local timer = require 'posix.time'
local Scalar = require 'libsclr'

local tests = {}
-- testing Q.index() to return index of value (num_elements < chunk_size)
tests.t1 = function()
  local tbl = {10,20,30,40,50,60,70,80,90,100}
  local qtype = "I4"
  local vec = utils.table_to_vector(tbl, qtype)
  local value = Scalar.new(50, "I4")
  local ind = Q.index(vec, value)
  assert(ind == 4, "wrong index returned")
  print("index of 50 is " .. ind)
  assert(type(vec) == 'lVector', "output not of type lVector")
  assert(vec:num_elements() == #tbl, "table and vector length not same")
  print("t1 test completed successfully")
end

-- testing Q.index to return index of value(num_elements > chunk_size)
-- value is present in last chunk at index (65536*5)-1
tests.t2 = function()
  local tbl = {}
  local qtype = "I4"
  
  for i = 1, 65536*5 do
    tbl[#tbl+1] = ( i * 10 ) % qconsts.qtypes[qtype].max
  end
  tbl[327679] = 9
  local vec = Q.mk_col(tbl, qtype)
  local value = Scalar.new(9, "I4")
  
  local start_time = timer.clock_gettime(0)
  local ind = Q.index(vec, value)
  local stop_time = timer.clock_gettime(0)
  local time =  (stop_time.tv_sec*10^6 +stop_time.tv_nsec/10^3 - (start_time.tv_sec*10^6 +start_time.tv_nsec/10^3))/10^6
  assert(ind == 327678, "wrong index returned")
  print("Index of 9 is " .. ind, " execution time = " .. time)
  print("t2 test completed successfully")
end

-- testing Q.index() to return nil in case it doesn't find value in vector
tests.t3 = function()
  local tbl = {10,20,30,40,50,60,70,80,90,100}
  local qtype = "I4"
  local value = Scalar.new(110, "I4")
  
  local vec = utils.table_to_vector(tbl, qtype)
  local ind = Q.index(vec, value)
  assert(ind==nil, "should return nil")
  print("t3 test completed successfully")
end

-- testing Q.index to return index of value(num_elements > chunk_size)
-- value is present in second chunk at index 65540
tests.t4 = function()
  local tbl = {}
  local qtype = "I4"
  
  for i = 1, 65536*3 do
    tbl[#tbl+1] = ( i * 10 ) % qconsts.qtypes[qtype].max
  end
  tbl[65541] = 9
  local value = Scalar.new(9, "I4")
  local vec = Q.mk_col(tbl, qtype)
  local ind = Q.index(vec, value)
  assert(ind == 65541-1, "wrong index returned")
  print("t4 test completed successfully")
end

-- testing Q.index() by giving input value of type number, 
-- it should return valid index
tests.t5 = function()
  local tbl = {10,20,30,40,50,60,70,80,90,100}
  local qtype = "I1"
  local value = 100
  local vec = Q.mk_col(tbl, qtype)
  local ind = Q.index(vec, value)
  assert(ind == 9, "wrong index returned")
  print("t5 test completed successfully")
end

-- testing Q.index() to return error in case of value > valid qtype range
tests.t6 = function()
  local tbl = {10,20,30,40,50,60,70,80,90,100}
  local qtype = "I1"
  local value = 128
  local vec = Q.mk_col(tbl, qtype)
  print("START: Deliberate error attempt")
  local status, reason = pcall(Q.index,vec, value)
  print("STOP: Deliberate error attempt")
  assert(status == false)
  print("t6 test completed successfully")
end

return tests
