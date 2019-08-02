gc_foo = require 'Q/RUNTIME/test/gc_foo'
local tests = {}
tests.t1 = function()
  local gc_foo = require 'gc_foo'
  local n = 1
  x = gc_foo(n)
  assert(type(x) == "table")
  local setter = x.setter
  local getter = x.getter
  assert(type(setter) == "function")
  assert(type(getter) == "function")
  local niters = 2048 * 1048576 - 1
  for i = 1, niters do 
    print(i)
    setter()
    local chk = getter()
    if ( i ~= chk ) then print(i, chk) end 
    assert(i == chk)
    collectgarbage()
  end
  print("Test t1 succeeded")
end
-- return tests
tests.t1()
