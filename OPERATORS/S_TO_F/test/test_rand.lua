-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
cVector.init_globals({})

local tests = {}
--========================================
tests.t1 = function()
  local csz = cVector.chunk_size()
  local len = csz * 19 + 3
  local probability = 0.25;
  local qtype = "B1"
  local seed = 1234
  local c1 = Q.rand( 
  { seed = seed, probability = probability, qtype = qtype, len = len })
  c1:eval()
  for i = 1, len do
    local val = c1:get1(i-1)
    assert(type(val) == "Scalar")
    assert(val:fldtype() == "B1")
  end
  assert(c1:qtype() == qtype)
  print("Test t1 succeeded")
end
tests.t2 = function()
  local csz = cVector.chunk_size()
  local len = csz * 19 + 3
  local lb = 17
  local ub = 1023
  local qtype = "F8"
  local seed = 1234
  local c1 = Q.rand( 
  { seed = seed, lb = lb, ub = ub, qtype = qtype, len = len })
  c1:eval()
  local slb = Scalar.new(lb, qtype)
  local sub = Scalar.new(ub, qtype)
  for i = 1, len do
    local val = c1:get1(i-1)
    assert(type(val) == "Scalar")
    assert(val:fldtype() == "F8")
    assert(val >= slb ) 
    assert(val <= sub ) 
  end
  assert(c1:qtype() == qtype)
  print("Test t2 succeeded")
end
tests.t1()
tests.t2()
return tests
