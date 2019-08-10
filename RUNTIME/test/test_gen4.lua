require 'Q/UTILS/lua/strict'
local lVector = require 'Q/RUNTIME/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'
local gen4 = require 'Q/RUNTIME/test/gen4'
  
local tests = {} 

--====== Testing nascent vector with generator(gen4)
tests.t1 = function()
  local T
  local x
  local len, base_data, nn_data

  print("Creating vector with generator")
  x = lVector( { qtype = "I4", gen = gen4, has_nulls = false} )

  T = x:meta()
  assert(T.base.is_nascent == true)
  assert(T.base.open_mode == "NOT_OPEN")

  -- for k, v in pairs(T.base)  do print(k,v) end
  -- for k, v in pairs(T.aux)  do print(k,v) end

  -- print("=========================================")

  assert(type(x) == "lVector")
  x:eval()

  T = x:meta()
  assert(T.base.is_nascent == true)
  assert(T.base.open_mode == "NOT_OPEN")
  assert(T.base.num_in_chunk == 10)
  assert(T.base.chunk_num == 3)

  -- for k, v in pairs(T.base)  do print(k,v) end
  -- for k, v in pairs(T.aux)  do print(k,v) end

  -- print("=========================================")

  len, base_data, nn_data = x:chunk(x:chunk_num())
  assert(base_data)
  assert(len == 10)

  T = x:meta()
  assert(T.base.is_nascent == true)
  assert(T.base.open_mode == "NOT_OPEN")
  assert(T.base.num_in_chunk == 10)
  assert(T.base.chunk_num == 3)

  -- for k, v in pairs(T.aux)  do print(k,v) end
  -- for k, v in pairs(T.base)  do print(k,v) end

  print("Call previous chunk");
  len, base_data, nn_data = x:chunk(0)
  assert(base_data)
  assert(len == qconsts.chunk_size)

  T = x:meta()
  assert(T.base.is_nascent == true)
  assert(T.base.open_mode == "READ")
  assert(T.base.num_in_chunk == 10)
  assert(T.base.chunk_num == 3)

  -- for k, v in pairs(T.base)  do print(k,v) end
  -- for k, v in pairs(T.aux)  do print(k,v) end

  print("Successfully completed test t1")
end

return tests
