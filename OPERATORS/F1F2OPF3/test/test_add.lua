-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
cVector.init_globals({})
local plpath  = require 'pl.path'
local chunk_size = cVector.chunk_size()

local tests = {}
tests.t1 = function()
  local qtype = "I4"
  local len = 2 * chunk_size + 3
  local x1 = {}; for i = 1, len do x1[i] = i end
  local x2 = {}; for i = 1, len do x2[i] = 2*i end

  local c1 = Q.mk_col(x1, qtype)
  local c2 = Q.mk_col(x2, qtype)
  print("Created input")
  assert(c1:num_elements() == len)
  assert(c2:num_elements() == len)
  local z = Q.vvadd(c1, c2):eval()
  for i = 1, len do 
    assert(z:get1(i-1) == Scalar.new(3*i, qtype))
  end
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
-- tests.t1()
