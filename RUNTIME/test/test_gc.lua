gc_foo = require 'Q/RUNTIME/test/gc_foo'
gc_bar = require 'Q/RUNTIME/test/gc_bar'
gc_xxx = require 'Q/RUNTIME/test/gc_xxx'
local tests = {}
tests.t1 = function()
  local gc_foo = require 'gc_foo'
  local gc_bar = require 'gc_bar'
  local gc_xxx = require 'gc_xxx'
  local n = 16*1048576
  x = gc_foo(n)
  x = gc_bar(n)
  x = gc_xxx(n)
  assert(type(x) == "table")
  local setter = x.setter
  local getter = x.getter
  assert(type(setter) == "function")
  assert(type(getter) == "function")
  local niters = 2048 * 1048576 - 1
  for i = 1, niters do 
    if ( ( i % 1024 ) == 0 ) then print(i) end 
    print(i)
    setter()
    local chk = getter()
    collectgarbage()
  end
  print("Test t1 succeeded")
end
return tests
-- tests.t1()
