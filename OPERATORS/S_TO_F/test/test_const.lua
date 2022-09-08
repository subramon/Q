-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local qcfg       = require 'Q/UTILS/lua/qcfg'
local Scalar     = require 'libsclr'
local max_num_in_chunk = 1024 -- just for testing 

local tests = {}
tests.t1 = function() 
  local val = (2048*1048576)-1
  local len = max_num_in_chunk * 2 + 3
  local qtype = "I4"
  local args = {
    val = val, 
    max_num_in_chunk  = max_num_in_chunk, 
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
  --[[
  for i = 1, len do
    assert(c1:get1(i-1):to_num() == val)
  end
  assert(c1:num_elements() == len)
  assert(c1:qtype() == qtype)
  -- TODO: What is the error we are trying to create?
  local status = pcall(c1.get1, len) -- deliberate error
  assert(not status)
  --]]
  print("Test t1 succeeded")
  -- os.exit() -- WHY IS THIS NEEDED? 
end
tests.t2 = function() 
  local len = max_num_in_chunk * 3 + 1941;
  local vals = { true, false }
  local qtype = "B1"
  for _, val in pairs(vals) do 
    local c1 = Q.const( {val = val, qtype = qtype, len = len })
    c1:eval()
    for i = 1, len do
      assert(c1:get1(i-1) == Scalar.new(val, "B1"))
    end
    assert(c1:num_elements() == len)
    local status = pcall(c1.get1, len) -- deliberate error
    assert(c1:qtype() == qtype)
  end
  print("Test t2 succeeded")
end
tests.t3 = function() -- this is a stress test 
  local val = 1
  local num_chunks = 1000 -- set this very large for a stress test
  local len = num_chunks * max_num_in_chunk 
  local qtype = "I4"
  local c1 = Q.const( {val = val, qtype = qtype, len = len }):memo(false)
  for i = 1, num_chunks do 
    local chunk_len = c1:get_chunk(i-1)
    assert(chunk_len == max_num_in_chunk)
    if ( ( i % 1000000 ) == 0 ) then print("i = ", i) end 
    c1:unget_chunk(i-1)
    local n1, n2 = c1:num_elements()
    assert(not n2)
    assert(n1 ==  i * max_num_in_chunk)
    collectgarbage()
  end
  c1:get_chunk(num_chunks)
  assert(c1:is_eov())
  assert(c1:eval())
  print("Test t3 succeeded")
end
tests.t1()
-- tests.t3()
-- tests.t2()
--[[
return tests
--]]
