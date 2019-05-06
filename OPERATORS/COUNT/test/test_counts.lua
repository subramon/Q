-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qconsts = require 'Q/UTILS/lua/q_consts'

local tests = {}

-- testing Q.count() to return correct count of a given value
tests.t1 = function()
  local tbl = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
  local qtype = "I1"
  local value = 100
  local vec = Q.mk_col(tbl, qtype)
  local result = Q.counts(vec, value)
  assert(result:eval():to_num() == 1)
  print("Successfully completed test t1")
end

-- testing Q.count() to return 0 in case of  0 occurence
tests.t2 = function()
  local tbl = {10, 20, 30, 40, 50, 60, 70, 80, 90, 100}
  local qtype = "I1"
  local value = 45
  local vec = Q.mk_col(tbl, qtype)
  local result = Q.counts(vec, value)
  assert(result:eval():to_num() == 0)
  print("Successfully completed test t2")
end


-- validating count operator to return count of a given number value
-- from input vector where num_elements < chunk_size
tests.t3 = function()
  local input_vec = Q.period({start = 1, by = 1, period = 10, len = 50000, qtype = "I2"}):eval()
  local result = Q.counts(input_vec, 10)
  assert(result:eval():to_num() == 5000)
  print("Successfully completed test t3")
end

-- validating count operator to return count of a given number value
-- from input vector where num_elements > chunk_size
tests.t4 = function()
  local input_vec = Q.period({start = 1, by = 1, period = 10, len = 65536*2, qtype = "I2"}):eval()
  local result = Q.counts(input_vec, 10)
  assert(result:eval():to_num() == 13107)
  print("Successfully completed test t4")
end

-- validating count operator to return count of a given scalar value
-- from input vector where num_elements > chunk_size
tests.t5 = function()
  local Scalar = require "libsclr"
  local qtype = "I2"
  local input_vec = Q.period({start = 1, by = 1, period = 10, len = 65536*2, qtype = qtype}):eval()
  local s_val = Scalar.new(10, qtype) 
  local result = Q.counts(input_vec, s_val)
  assert(result:eval():to_num() == 13107)
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
  local status, reason = pcall(Q.counts,vec, value)
  print(status, reason)
  print("STOP: Deliberate error attempt")
  assert(status == false)
  print("Successfully completed test t6")
end

return tests
