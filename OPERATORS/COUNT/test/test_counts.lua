-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local Scalar = require 'libsclr'
local qcfg   = require 'Q/UTILS/lua/qcfg'
local nC = qcfg.max_num_in_chunk


local tests = {}

-- testing Q.count() to return correct count of a given value
tests.t1 = function()
  local tbl = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
  local qtype = "I1"
  local value = 100
  local vec = Q.mk_col(tbl, qtype)
  local rdcr = Q.count(vec, value)
  assert(type(rdcr) == "Reducer")
  local n1 = rdcr:eval()
  assert(n1:to_num() == 1)
  print("Successfully completed test t1")
end

-- testing Q.count() to return 0 in case of  0 occurence
tests.t2 = function()
  local tbl = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
  local qtype = "I1"
  local value = 45
  local vec = Q.mk_col(tbl, qtype)
  local result = Q.count(vec, value)
  assert(result:eval():to_num() == 0)
  print("Successfully completed test t2")
end

-- testing with num_elements >, <, == chunk_size
tests.t3 = function()
  local nC = 128
  for iter = 1, 3 do 
    local len
    if ( iter == 1 ) then 
      len = nC - 7 
    elseif ( iter == 2 ) then 
      len = nC + 7 
    else
      len = nC
    end
    local args = {start = 1, by = 1, period = 10, len = len, 
      qtype = "I2", max_num_in_chunk = nC}
    local input_vec = Q.period(args)
    local rdcr = Q.count(input_vec, 10)
    assert(type(rdcr) == "Reducer")
    local count = rdcr:eval()
    assert(type(count) == "Scalar")
    count = count:to_num()
    if ( iter == 1 ) then assert(count == 12 ) 
    elseif ( iter == 2 ) then assert(count == 13 ) 
    elseif ( iter == 3 ) then assert(count == 12 ) 
    else error("XXX") end
  end
  print("Successfully completed test t3")
end

-- validating count operator to return count of a given scalar value
-- from input vector where num_elements > chunk_size
tests.t5 = function()
  local nC = 256
  local Scalar = require "libsclr"
  local qtype = "I2"
  local len = nC*2
  local input_vec = Q.period({start = 1, by = 1, period = 10, len = len, qtype = qtype, max_num_in_chunk = nC}):eval()
  local s_val = Scalar.new(10, qtype) 
  local rdcr = Q.count(input_vec, s_val)
  local count = rdcr:eval()
  count = count:to_num()
  assert(count == 51)
  print("Successfully completed test t5")
end

-- negative test case
-- testing Q.count() to return error in case of value > valid qtype range
tests.t6 = function()
  local tbl = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
  local qtype = "I1"
  local value = 128
  local vec = Q.mk_col(tbl, qtype)
  print("START: Deliberate error attempt")
  local status, reason = pcall(Q.count,vec, value)
  print(status, reason)
  print("STOP: Deliberate error attempt")
  assert(status == false)
  print("Successfully completed test t6")
end

tests.t1()
tests.t2()
tests.t3()
tests.t5()
tests.t6()

--return tests
