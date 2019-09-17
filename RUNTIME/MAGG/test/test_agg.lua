local lVector = require 'Q/RUNTIME/lua/lVector'
local lAggregator = require 'Q/RUNTIME/MAGG/lua/lAggregator'

local tests = {}
tests.t1 = function(n, niters)
  local n = n or 1000
  local niters = niters or 10000
  -- create an aggregator, should work
  local T1 = require 'Q/RUNTIME/MAGG/lua/test1'
  local A = lAggregator(T1, "libtest1.so", "test1")
  A:instantiate()
  for i = 1, n do
    A:put1(100+i, { 10, 20, 30, 40 })
  end
  local M = A:meta()
  -- for k, v in pairs(M) do print(k, v) end 
  assert(M.nitems == n)
  for i = 1, n do
    local is_found, cnt, oldval = A:get1(100+i)
    assert(is_found == true)
    assert(cnt == 1)
    assert(oldval[1]:to_num() == 10)
    assert(oldval[2]:to_num() == 20)
    assert(oldval[3]:to_num() == 30)
    assert(oldval[4]:to_num() == 40)
    --====================
    local is_found, oldval = A:del1(100+i)
    assert(is_found == true)
    assert(oldval[1]:to_num() == 10)
    assert(oldval[2]:to_num() == 20)
    assert(oldval[3]:to_num() == 30)
    assert(oldval[4]:to_num() == 40)
    
  end
  local M = A:meta()
  assert(M.nitems == 0)
  --== testing bufferizing
  for i = 1, niters do  -- set to large number for stress testing
    A:bufferize()
    A:unbufferize()
  end
  --== testing setting/unsetting produce
  local x = lVector( { qtype = "I8", gen = true, has_nulls = false})
  for i = 1, niters do  -- set to large number for stress testing
    A:set_produce(x)
    A:unset_produce()
  end
  --======================
  print("Success on test t1")
end
-- return tests
tests.t1()
