local Q = require 'Q'
local lVector = require 'Q/RUNTIME/lua/lVector'
local tests = {}

tests.t1 = function()
  local vec1 = lVector({qtype = "I4", gen = true})
  assert(vec1:is_memo() == true) -- default value of qconsts.is_memo is true
  Q.set_memo(false) -- value of qconsts.is_memo set to false
  local vec2 = lVector({qtype = "I4", gen = true})
  assert(vec2:is_memo() == false)
  local vec3 = lVector({qtype = "I4", gen = true, is_memo = true})
  assert(vec3:is_memo() == true) -- is_memo field in vec args has priority
  print("Successfully completed test t1")
end

return tests
