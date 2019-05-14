lAggregator = require 'Q/RUNTIME/AGG/lua/lAggregator'
Scalar = require 'libsclr'

local tests = {}
tests.t1 = function()
  local params = { initial_size = 1024, keytype = "I4", valtype = "I4"}
  local x = lAggregator(params)
  print("Success on test t1")
end
tests.t2 = function()
  local params = { initial_size = 1024, keytype = "I4", valtype = "F4"}
  local A = lAggregator(params)
  A:set_input_mode(true)
  local key = Scalar.new(123, "I8")
  local val = Scalar.new(456, "F4")
  local oldval = A:put1(key, val)
  assert(type(oldval) == "Scalar")
  -- print(type(oldval))
  -- print(oldval)
  assert(oldval == Scalar.new(0, "F4"))
  --============================================
  local chkval = A:get1(key)
  assert(type(chkval) == "Scalar")
  -- print(chkval)
  -- print(chkval:fldtype())
  assert(chkval == Scalar.new(456, "F4"))
  print("Success on test t2")
  
end
return tests
