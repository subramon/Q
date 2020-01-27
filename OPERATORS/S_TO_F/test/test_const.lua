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
  local c1 = Q.const( {val = val, qtype = qtype, len = len })
  c1:eval()
  for i = 1, len do
    assert(c1:get1(i-1):to_num() == val)
  end
  assert(c1:num_elements() == len)
  assert(c1:qtype() == qtype)
  print("Test t1 succeeded")
end
tests.t2 = function() 
  local len = cVector.chunk_size() * 3 + 1941;
  local vals = { true, false}
  local qtype = "B1"
  for _, val in vals do 
    local ival 
    if ( val == true ) then ival = 1 else ival = 0 end 
    local c1 = Q.const( {val = val, qtype = qtype, len = len })
    c1:eval()
    for i = 1, len do
      assert(c1:get1(i-1):to_num() == ival)
    end
  end
  assert(c1:len() == len)
  assert(c1:qtype() == qtype)
  print("Test t2 succeeded")
end
tests.t1()
os.exit()
-- tests.t2()
-- return tests
