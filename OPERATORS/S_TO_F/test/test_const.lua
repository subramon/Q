-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qcfg     = require 'Q/UTILS/lua/qcfg'
local Scalar   = require 'libsclr'
local cVector  = require 'libvctr'
local lgutils  = require 'liblgutils'
local lgutils  = require 'liblgutils'

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
  local c1 = Q.const(args):set_name("c1")
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
  assert(c1 == c2)
  local ival = c1:get1(len)
  assert(c2:check())
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
  c1:delete()

  -- make a few more vectors just for fun
  local c3 = Q.const(args):set_name("c3"):eval()
  local c4 = Q.const(args):set_name("c4"):eval()
  c3:delete()
  c4:delete()

  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  assert(cVector.check_all(true, true)) -- checking on all vectors
  print("Test t1 succeeded")
end
tests.t2 = function() 
  local len = blksz + 19;
  local vals = { true, false }
  local qtype = "B1"
  for k, val in pairs(vals) do 
    local c1 = Q.const( {val = val, qtype = qtype, len = len })
    assert(c1:qtype() == "B1")
    c1:eval()
    c1:set_name("vec_" .. tostring(val))
    -- c1:pr()
    local chk_sclr = Scalar.new(val, "BL")
    for i = 65, len do
      local sclr = c1:get1(i-1)
      assert(type(sclr) == "Scalar")
      assert(sclr:qtype() == "BL")
      assert(sclr == chk_sclr)
    end
    assert(c1:num_elements() == len)
    assert(c1:qtype() == qtype)
    print(">>> START Deliberate error")
    local status = pcall(c1.get1, len) -- deliberate error
    assert(not status)
    print("<<< STOP  Deliberate error")
    c1:delete()
  end
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  assert(cVector.check_all(true, true)) -- checking on all vectors
  print("Test t2 succeeded")

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
  c1:delete()
  print("Test t3 succeeded")
  assert(cVector.check_all(true, true)) -- checking on all vectors
end
-- test t4 is to handle const B1 case
tests.t4 = function() 
  local len = blksz + 17 
  for _, val in ipairs({true, false}) do 
    local c1 = Q.const( {val = val, qtype = "B1", len = len })
    c1:eval()
    for i = 1, len do 
      local chk_val = c1:get1(i-1)
      assert(chk_val == Scalar.new(val, "BL"))
    end
    c1:delete()
    print("Test t4 succeeded for B1 = " .. tostring(val))
  end
  
  assert(cVector.check_all(true, true)) -- checking on all vectors
  print("Test t4 succeeded")
end

tests.t1() 
tests.t2()
tests.t3()
tests.t4()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
--[[
return tests
--]]
