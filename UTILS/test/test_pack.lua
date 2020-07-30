local strict  = require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local qconst  = require 'Q/UTILS/lua/q_consts'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local chunk_size = cVector.chunk_size()

local tests = {}

-- Q.pack to return vector of given input number values
tests.t1 = function()
  local tbl = {10,20,30,40,50}
  local qtype = "I1"
  local vec = Q.pack(tbl, qtype)
  assert( type(vec) == "lVector" )
  assert(vec:length() == 5 )
  for i = 0, #tbl-1 do
    assert(vec:get1(i):to_num() == tbl[i+1])
  end
  print("successfully executed t1")
end

-- negative test-case:
-- Q.pack to return error as max_limit is crossed
-- by requesting num_elements to be more than 1024
tests.t2 = function()
  local num_elements = chunk_size + 4
  local qtype = "I4"
  local tbl = {}
  for i = 1, num_elements do
    tbl[#tbl+1] = i
  end
  local vec = pcall(Q.pack, tbl , qtype)
  assert(vec == false)
  print("successfully executed t2")

  print("successfully executed t2")
end

-- Q.pack to return vector of given input scalar values
tests.t3 = function()
  local tbl = {10,20,30,40,50}
  local qtype = "I1"
  local input_tbl = {}
  for i=1, #tbl do
    input_tbl[#input_tbl +1] = Scalar.new(tbl[i], qtype)
  end
  local vec = Q.pack(input_tbl, qtype)
  assert( type(vec) == "lVector" )
  assert(vec:length() == 5 )
  for i = 0, #tbl-1 do
    assert(vec:get1(i):to_num() == tbl[i+1])
  end
  print("successfully executed t3")
end

return tests
