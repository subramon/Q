local Q           = require 'Q'
local qconsts     = require 'Q/UTILS/lua/q_consts'
local lVector     = require 'Q/RUNTIME/lua/lVector'
local lAggregator = require 'Q/RUNTIME/MAGG/lua/lAggregator'

local tests = {}
tests.t1 = function(n, niters)
  local n = n or 1000
  local niters = niters or 10000
  -- create an aggregator, should work
  local T1 = require 'Q/RUNTIME/MAGG/lua/test1'
  local A = lAggregator(T1, "libaggtest1")
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
  local k = lVector( { qtype = "I8", gen = true, has_nulls = false})
  for i = 1, niters do  -- set to large number for stress testing
    A:set_produce(k)
    A:unset_produce()
  end
  --== testing setting consume
  local v1 = lVector( { qtype = "F4", gen = true, has_nulls = false})
  local v2 = lVector( { qtype = "I1", gen = true, has_nulls = false})
  local v3 = lVector( { qtype = "I2", gen = true, has_nulls = false})
  local v4 = lVector( { qtype = "I4", gen = true, has_nulls = false})
  local y
  assert(A:set_consume(k, { v1, v2, v3, v4}))
  y = A:is_dead()
  assert(y == false)
  y = A:is_instantiated()
  assert(y == true)
  y = A:is_bufferized()
  assert(y == false)
  status, msg = pcall(A.set_consume, A, k, { v1, v2, v3, v4})
  assert( not status)
  print(msg)
  print("Success on test t1")
end
tests.t2 = function(n)
  local n = n or 1000
  --======================
  -- create an aggregator, should work
  local T1 = require 'Q/RUNTIME/MAGG/lua/test1'
  local A = lAggregator(T1, "libaggtest1")
  --======================
  local num_vals = 4
  local  k = Q.seq({ qtype = "I8", start = 1, by = 1, len = n})
  local v1 = Q.seq({ qtype = "F4", start = 1, by = 1, len = n})
  local v2 = Q.seq({ qtype = "I1", start = 1, by = 1, len = n})
  local v3 = Q.seq({ qtype = "I2", start = 1, by = 1, len = n})
  local v4 = Q.seq({ qtype = "I4", start = 1, by = 1, len = n})
  -- Q.print_csv({k, v1, v2, v3, v4})
  assert(A:set_consume(k, { v1, v2, v3, v4}))
  local num_consumed = A:consume()
  if ( qconsts.chunk_size >= num_consumed ) then 
    assert(num_consumed == n)
  else
    assert(num_consumed == qconsts.chunk_size)
  end
  local M = A:meta()
  assert(M.nitems == num_consumed)
  local num_consumed = A:consume()
  assert(num_consumed == 0 )
  Vs = A:set_produce(k)
  assert(type(Vs) == "table")
  assert(#Vs == num_vals) 
  assert(Vs[1]:fldtype() == "F4")
  assert(Vs[2]:fldtype() == "I1")
  assert(Vs[3]:fldtype() == "I2")
  assert(Vs[4]:fldtype() == "I4")
  print("Success on test t2")
end
-- return tests
tests.t2()
  os.exit()
