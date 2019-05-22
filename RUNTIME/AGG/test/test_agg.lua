lAggregator = require 'Q/RUNTIME/AGG/lua/lAggregator'
Scalar = require 'libsclr'

local tests = {}
tests.t1 = function()
  -- create an aggregator, should work
  local params = { initial_size = 1024, keytype = "I4", valtype = "I4"}
  local x = lAggregator(params)
  print("Success on test t1")
end
tests.t2 = function()
  -- create an aggregator
  -- put an item as (key=k, val=v), should work. 
  -- get item with key k, should exist and have value v
  -- delete item with key k, should work and return old value v
  -- get item with key k, should get null
  local params = { initial_size = 1024, keytype = "I4", valtype = "F4"}
  local A = lAggregator(params)
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
  assert(type(chkval) == "nil")
  --============================================
  print("Success on test t2")
  
end
tests.t3 = function(n)
  n = n or 32*1048576
  -- cretae large number of Aggregators. 
  -- Iteration 1: explicitly delete
  -- Iteration 2: have Lua do deletion 
  local params = { initial_size = 1048576, keytype = "I4", valtype = "F4"}
  for j = 1, 2 do 
    for i = 1, n do
      local A = lAggregator(params)
      -- if ( ( i % 1048576 ) == 0 ) then print("Iteration ", i) end
      if ( j == 1 ) then 
        A:delete()
      end
    end
  end
  --============================================
  print("Success on test t3")
end
tests.t4 = function(n)
  -- create aggregator, put large number of values for same key
  -- every get should get back last value  put
  -- note that update_type = set is default
  local params = { initial_size = 1048576, keytype = "I4", valtype = "F4"}
  n = n or 32*1048576
  local A = lAggregator(params)
  local key = Scalar.new(1, "I4")
  local oldval = A:put1(key,  Scalar.new(0, "F4"))
  local chkval, newval
  for i = 1, n do
    chkval = A:get1(key)
    newval = Scalar.new(i, "F4")
    local oldval = A:put1(key, newval)
    assert(oldval == chkval)
    oldval = newval
  end
  --============================================
  print("Success on test t4")
end
tests.t5 = function(n)
  -- to test update_type = sum
  -- use same key and values = 1, 2, 3, ..., i, ... n
  -- at each point it should be i*(i+1)/2
  local params = { initial_size = 1048576, keytype = "I4", valtype = "F4"}
  n = n or 65536
  local A = lAggregator(params)
  local key = Scalar.new(1, "I4")
  local oldval = A:put1(key,  Scalar.new(0, "F4"))
  local sumval = Scalar.new(0, "F4")
  local chkval, newval
  for i = 1, n do
    newval = Scalar.new(i, "F4")
    A:put1(key, newval, "ADD")
    chkval = A:get1(key)
    sumval = sumval + newval
    assert(sumval == chkval)
  end
  --============================================
  print("Success on test t5")
end
return tests
