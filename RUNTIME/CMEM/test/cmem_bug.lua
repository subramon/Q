local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'

local function t5()
  -- print("Creating nascent vector with generator")
  local gen1 = require 'Q/RUNTIME/test/gen1'
  local x = lVector( { qtype = "I4", gen = gen1, has_nulls = false, name = "x"} )

  local x_num_chunks = 10
  local num_chunks = 0
  local chunk_size = qconsts.chunk_size
  for chunk_num = 1, x_num_chunks do 
    local a, b, c = x:chunk(chunk_num-1)
    assert(a)
    if ( b ) then assert(type(b) == "CMEM") end
    assert(c == nil)
    if ( a < chunk_size ) then 
      print("Breaking on chunk", chunk_num); 
      assert(x:is_eov() == true)
      break 
    end
    num_chunks = num_chunks + 1
    print(a,  chunk_size)
    assert(a == chunk_size)
    x:check()
  end
    collectgarbage()
  local status = pcall(x.eov)
  assert(not status)
  local T = x:meta()
  print("Successfully completed test t5")
end

t5()
