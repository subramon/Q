local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local tests = {}
tests.t1 = function()
  local x, y = lVector({ qtype = "F4", width = 4, chunk_size = 0 })
  assert(type(x) == "lVector")
  assert(type(y) == "nil") -- only one thing returned
  x = nil
  collectgarbage()
  print("Test t1 succeeded")
end
tests.t2 = function()
  local qtype = "I4"
  local x = lVector({ qtype = "F4", chunk_size = 16 })
  assert(type(x) == "lVector")
  assert(x:num_elements() == 0)
  assert(x:is_eov() == false)
  print("Test t2 succeeded")
end
-- return tests
tests.t1()
tests.t2()
