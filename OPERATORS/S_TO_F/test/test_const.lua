-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qcfg       = require 'Q/UTILS/lua/qcfg'
local Scalar     = require 'libsclr'

local blksz = qcfg.max_num_in_chunk 
local tests = {}
tests.t1 = function() 
  local val = (2048*1048576)-1
  local len = blksz * 2 + 3
  local qtype = "I4"
  local args = {
    val = val, 
    qtype = qtype, 
    len = len 
  }
  print("Calling const")
  local c1 = Q.const(args)
  assert(c1:memo_len() == qcfg.memo_len)

  local memo_len = 2
  assert(c1:memo(memo_len))
  assert(c1:memo_len() == memo_len)

  local c2 = c1:eval()
  assert(type(c2) == "lVector")

  local chk_val = Scalar.new(val, qtype)
  local lb = blksz+1 -- to ignore block 0 
  for i = lb, len do
    local ival = c1:get1(i-1)
    if ( ( i >= 1 ) and ( i <= blksz ) ) then
      assert(type(ival) == "nil")
      --  because of memo, we should have lost chunk 0
     else
       assert(type(ival) == "Scalar")
       assert(ival == chk_val)
     end
  end
  print(">>> START Deliberate error")
  local ival = c1:get1(len)
  assert(ival == nil)
  local ival = c1:get1(-1)
  assert(ival == nil)
  print("<<< STOP  Deliberate error")
  
  assert(c1:num_elements() == len)
  assert(c1:qtype() == qtype)
  -- Asking for index too high or too low should cause a problem
  local status = pcall(c1.get1, len) -- deliberate error
  assert(not status)
  local status = pcall(c1.get1, -1) -- deliberate error
  assert(not status)

  -- make a few more vectors just for fun
  local c3 = Q.const(args):eval()
  local c4 = Q.const(args):eval()
  assert(c1:check(true, true)) -- checking on all vectors
  print("Test t1 succeeded")
  -- os.exit() -- WHY IS THIS NEEDED? 
end
tests.t2 = function() 
  print("B1 not implemented ")
  --[[
  local len = blksz * 3 + 19;
  local vals = { true, false }
  local qtype = "B1"
  for _, val in pairs(vals) do 
    local c1 = Q.const( {val = val, qtype = qtype, len = len })
    c1:eval()
    local sclr = Scalar.new(val, "B1")
    print("testing const_B1 with value " .. tostring(val))
    for i = 1, len do
      assert(c1:get1(i-1) == sclr)
    end
    assert(c1:num_elements() == len)
    assert(c1:qtype() == qtype)
    print(">>> START Deliberate error")
    local status = pcall(c1.get1, len) -- deliberate error
    assert(not status)
    print("<<< STOP  Deliberate error")
  end
  print("Test t2 succeeded")
  --]]
end
tests.t3 = function() -- this is a stress test 
  local val = 1
  local num_chunks = 10 -- set this very large for a stress test
  local len = num_chunks * blksz 
  local qtype = "I4"
  local c1 = Q.const( {val = val, qtype = qtype, len = len })
  c1:memo(2)
  c1:eval()
  assert(c1:is_eov())
  assert(c1:check(true, true)) -- checking on all vectors
  print("Test t3 succeeded")
  os.exit() -- WHY IS THIS NEEDED?
end
tests.t1()
-- tests.t2()
tests.t3()
--[[
return tests
--]]
