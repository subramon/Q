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
  --============================================
  local chkval = A:del1(key)
  assert(type(chkval) == "Scalar")
  -- print(chkval)
  -- print(chkval:fldtype())
  assert(chkval == Scalar.new(456, "F4"))
  --============================================
  local chkval = A:get1(key)
  print("XXX", chkval)
  assert(not chkval)
  --============================================
  print("Success on test t2")
  
end
tests.t3 = function(n)
  n = n or 32*1048576
  local params = { initial_size = 1048576, keytype = "I4", valtype = "F4"}
  for i = 1, n do
    local A = lAggregator(params)
    A:set_input_mode(true)
    if ( ( i % 1048576 ) == 0 ) then
      print("Iteration ", i)
    end
    A:delete()
  end
  --============================================
  print("Success on test t3")
end
return tests
