--[[
Steps to modify chunk_size to 64
- set qconsts.chunk_size to 64 in UTILS/lua/q_consts.lua
- modify Q_CHUNK_SIZE constant to 64 in UTILS/inc/q_constants.h
- rebuild Q
]]

-- For all tests, set chunk size to 64
-- Weird behavior: if I uncomment Q.print_csv() statement from below tests then all tests works except t1

-- Date 9/12/2017 - now not observing weird behavior because of fix in vector code

local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'

local tests = {}

-- Problem with MK_COL
-- mk_col for B1 with values more than chunk size not working correctly, 
-- for second chunk it gives wrong values
tests.t1 = function()
  local input_table = {}
  for i=1, 65536 do
    input_table[i] = 1
  end
  input_table[655537] = 0
  input_table[65538] = 1
  local b = Q.mk_col(input_table, "B1")
  -- Q.print_csv(b, nil, "/tmp/b_out.txt")
  for i = 1, b:length() do
    val, nn_val = c_to_txt(b, i)
    if not val then
      val = 0
    end
    assert(val == input_table[i], "Mismatch at index " .. i .. ", expected: " .. input_table[i] .. ", actual: " .. val)
  end
  -- Q.print_csv(b, nil, "/tmp/mk_col_B1_out.txt")  
end


-- Problem with Seq
-- When specifying len greater than chunk_size, the first value I am getting is zero instead of start value.
-- But if I set len equal to chunk_size or less than that then getting proper values.
tests.t2 = function()
  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 65540} )
  a:eval()
  -- Q.print_csv(a, nil, "/tmp/seq_out")
  val, nn_val = c_to_txt(a, 1)  
  assert(val == 1)
end


-- Problem with vvadd
-- Not getting proper result when using vector with length greater than chunk_size
tests.t3 = function()
  local a_input_table = {}
  for i=1, 65538 do
    a_input_table[i] = i
  end
  local a = Q.mk_col(a_input_table, "I4")
  -- Q.print_csv(a, nil, "/tmp/a_out.txt")  
  local b = Q.mk_col(a_input_table, "I4")
  -- Q.print_csv(b, nil, "/tmp/b_out.txt")  
  local res = Q.vvadd(a, b)
  res:eval()
  -- Q.print_csv(res, nil, "/tmp/vvadd_out.txt")
  for i = 1, a:length() do
    val, nn_val = c_to_txt(res, i)  
    assert(val == a_input_table[i] * 2, "Mismatch at index " .. i .. ", expected: " .. a_input_table[i] * 2 .. ", actual " .. val)  end
end

-- Problem with sum
-- Not getting correct result with Q.sum
tests.t4 = function()
  local a_input_table = {}
  for i=1, 65538 do
    a_input_table[i] = i
  end
  local a = Q.mk_col(a_input_table, "I4")  
  -- Q.print_csv(a, nil, "/tmp/a_out.txt")
  local res = Q.sum(a):eval():to_num()
  assert(res == ( ( 65538 * 65539 ) / 2 ) )
  
  local b = Q.seq({start = 1, by = 1, qtype = "I4", len = 65538})
  b:eval()
  -- Q.print_csv(b, nil, "/tmp/b_out.txt")
  res = Q.sum(b):eval():to_num()
  assert(res == ( ( 65538 * 65539 ) / 2 ) )
end

return tests
