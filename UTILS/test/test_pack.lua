local strict  = require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local Scalar  = require 'libsclr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local max_num_in_chunk = qcfg.max_num_in_chunk

local tests = {}

-- Q.pack to return vector of given input number values
tests.t1 = function()
  local tbl = {10,20,30,40,50}
  local qtype = "I1"
  local vec = Q.pack(tbl, qtype)
  assert( type(vec) == "lVector" )
  assert(vec:num_elements() == 5 )
  for i = 0, #tbl-1 do
    assert(vec:get1(i):to_num() == tbl[i+1])
  end
  print("successfully executed t1")
end

-- Q.pack to return vector of given input scalar values
tests.t2 = function()
  local tbl = {10,20,30,40,50}
  local qtype = "I1"
  local input_tbl = {}
  for i=1, #tbl do
    input_tbl[#input_tbl +1] = Scalar.new(tbl[i], qtype)
  end
  local vec = Q.pack(input_tbl, qtype)
  assert( type(vec) == "lVector" )
  assert(vec:num_elements() == 5 )
  for i = 0, #tbl-1 do
    assert(vec:get1(i):to_num() == tbl[i+1])
  end
  print("successfully executed t2")
end

-- return tests
tests.t1()
tests.t2()
