-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local cutils = require 'libcutils'
local Scalar  = require 'libsclr'
local qcfg = require 'Q/UTILS/lua/qcfg'
local chunk_size = qcfg.max_num_in_chunk

local tests = {}
--========================================
tests.t1 = function()
  local csz = chunk_size
  local len = csz * 19 + 3
  local probability = 0.25;
  local qtype = "B1"
  local seed = 1234
  local c1 = Q.rand( 
  { seed = seed, probability = probability, qtype = qtype, len = len })
  c1:eval()
  local num_true = 0
  local strue = Scalar.new(true, "B1")
  for i = 1, len do
    local val = c1:get1(i-1)
    assert(type(val) == "Scalar")
    assert(val:fldtype() == "B1")
    if ( val == strue ) then num_true = num_true + 1 end 
  end
  assert(c1:qtype() == qtype)
  print("B1, num_true, len = ", num_true, len)
  local ratio = num_true / len
  local lb = probability - 0.2
  local ub = probability + 0.2
  assert ( ( ratio >= lb ) and ( ratio <= ub ) ) 
  print("Test t1 succeeded")
end
tests.t2 = function()
  local csz = chunk_size
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
    assert(val:qtype() == "F8")
    assert(val >= slb ) 
    assert(val <= sub ) 
  end
  assert(c1:qtype() == qtype)
  -- c1:pr()
  print("Test t2 succeeded")
end
-- tests.t1() TODO causes segfault 
tests.t2()
-- return tests
