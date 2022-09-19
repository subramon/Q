local strict  = require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local max_num_in_chunk = qcfg.max_num_in_chunk

local tests = {}

-- Q.unpack to return table of scalar value
tests.t1 = function()
  local vec = Q.mk_col({10,20,30,40,50}, "I1")
  local tbl = Q.unpack(vec)
  assert( type(tbl) == "table" )
  assert( #tbl == 5 )
  for i = 1 , #tbl do
    assert(type(tbl[i]) == "Scalar")
    assert(tbl[i]:to_num() == i * 10)
  end
  print("successfully executed t1")
end

-- Q.unpack to evaluate vector internally 
-- test-case for num_elements > max_num_in_chunk
tests.t2 = function()
  local num_elements = max_num_in_chunk + 4
  local vec = Q.seq({ start = 1, by = 1, len = num_elements , qtype = "I4"})
  local tbl = Q.unpack(vec)
  assert( type(tbl) == "table" )
  assert( #tbl == num_elements)
  for i = 1 , #tbl do
    assert(type(tbl[i]) == "Scalar")
    assert(tbl[i]:to_num() == i)
  end
  print("successfully executed t2")
end

-- return tests
tests.t1()
tests.t2()
