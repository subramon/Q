-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'
local cVector = require 'libvctr'
cVector.init_globals({})

local tests = {}
tests.t1 = function() 
  local val = (2048*1048576)-1
  local len = cVector.chunk_size() * 2 + 3
  local qtype = "I4"
  local c1 = Q.const( {val = val, qtype = qtype, len = len }):memo(true)
  c1:eval()
  for i = 1, len do
    assert(c1:get1(i-1):to_num() == val)
  end
  assert(c1:num_elements() == len)
  local status = pcall(c1.get1, len) -- deliberate error
  assert(not status)
  assert(c1:qtype() == qtype)
  print("Test t1 succeeded")
end
tests.t2 = function() 
  local len = cVector.chunk_size() * 3 + 1941;
  local vals = { true, false }
  local qtype = "B1"
  for _, val in pairs(vals) do 
    local ival 
    if ( val == true ) then ival = 1 else ival = 0 end 
    local c1 = Q.const( {val = val, qtype = qtype, len = len })
    c1:eval()
    for i = 1, len do
      assert(c1:get1(i-1):to_num() == ival)
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
  local len = num_chunks * cVector.chunk_size() 
  local qtype = "I4"
  local c1 = Q.const( {val = val, qtype = qtype, len = len }):memo(false)
  for i = 1, num_chunks do 
    local chunk_len = c1:get_chunk(i-1)
    assert(chunk_len == cVector.chunk_size())
    if ( ( i % 1000000 ) == 0 ) then print("i = ", i) end 
    c1:unget_chunk(i-1)
    local n1, n2 = c1:num_elements()
    assert(not n2)
    assert(n1 ==  i * cVector.chunk_size())
    collectgarbage()
  end
  c1:get_chunk(num_chunks)
  assert(c1:is_eov())
  assert(c1:eval())
  print("Test t3 succeeded")
end
--[[
tests.t1()
tests.t2()
tests.t3()
os.exit()
--]]
return tests
