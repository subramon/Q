-- FUNCTIONAL 
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local qconsts = require 'Q/UTILS/lua/q_consts'

local tests = {}
tests.t1 = function() 
  local num = (2048*1048576)-1
  local c1 = Q.const( {val = num, qtype = "I4", len = 8000000 })
  local minval = Q.min(c1):eval():to_num()
  local maxval = Q.max(c1):eval():to_num()
  assert(minval == num)
  assert(maxval == num)
  print("Test t1 succeeded")
end
tests.t2 = function() 
  local len = qconsts.chunk_size * 3 + 1941;
  for val = 0, 2 do 
    if ( val > 1 ) then 
      
      local status = pcall(Q.const, {val = val, qtype = "B1", len = len })
      assert(not status )
    else
      --[[TODO Need to implement min/max for B1
      local c1 = Q.const( {val = val, qtype = "B1", len = len })

      local minval = Q.min(c1):eval():to_num()
      local maxval = Q.max(c1):eval():to_num()
      assert(minval == maxval)
      assert(minval == val)
      --]]
    end
  end
  print("Test t2 succeeded")
end
tests.t3 = function() 
  local len = 1941;
  local ival
  for _, val in pairs({true, false}) do
    if ( val == true ) then ival = 1 end
    if ( val == false ) then ival = 0 end
    local c1 = Q.const( {val = val, qtype = "B1", len = len }):eval()
    for i = 1, len do
      assert(c1:get_one(i-1):to_num() == ival)
    end
  end
  print("Test t3 succeeded")
end
return tests
