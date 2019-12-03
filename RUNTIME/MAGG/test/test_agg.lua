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
    oldvals, is_updated = A:put1(100+i, { 10, 20, 30, 40 })
    assert(type(is_updated) == "boolean")
    assert(type(oldvals) == "table")
    assert(#oldvals == #{ 10, 20, 30, 40 })
    assert(is_updated == false) -- key being put for first time 
    for k, v in ipairs(oldvals) do 
      assert(v:to_num() == 0) -- oldval = 0 because key did not exist prior
    end
  end
  local M = A:meta()

  -- for i, v in pairs(M) do print(i, v) end 
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
  -- ==============================================
  -- look for keys that are not there. Should get back false
  for i = 1, n do
    local is_found, cnt, oldval = A:get1(100+n+i)
    assert(is_found == false)
  end
  -- ==============================================
  -- if we put the same thing again, the cnt should become 2 on get
  for i = 1, n do 
    A:put1(100+i, { 10, 20, 30, 40 })
    A:put1(100+i, { 10, 20, 30, 40 })
    local is_found, cnt, oldval = A:get1(100+i)
    assert(cnt == 2, cnt)
  end
  --==============================================
  --== testing bufferizing
  for i = 1, niters do  -- set to large number for stress testing
    A:bufferize()
    A:unbufferize()
  end
  -- START testing freezing
  local M = A:meta()
  A:freeze()
  local status, msg = pcall(A.put1, A, 102, { 10, 20, 30, 40})
  assert(not status)
  A:unfreeze()
  local status, msg = pcall(A.put1, A, 102, { 10, 20, 30, 40})
  assert(status)
  -- STOP testing freezing
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
  local  k = Q.seq({ qtype = "I8", start = 1, by = 1, len = n})
  local vtypes = { "F4", "I1", "I2", "I4" }
  local num_vals = #vtypes
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
  local inVs = { v1, v2, v3, v4 }
  local outVs = A:set_produce(k)
  assert(type(outVs) == "table")
  assert(#outVs == num_vals) 
  for j = 1, #vtypes do 
    assert(outVs[j]:fldtype() == vtypes[j])
  end
  for j = 1, #vtypes do 
    assert(outVs[j]:eval())
  end
  for j = 1, num_vals do 
    assert(outVs[j]:is_eov())
  end
  -- Q.print_csv(outVs)
  for j = 1, num_vals do 
    local n1, n2 = Q.sum(Q.vveq(inVs[j], outVs[j])):eval()
    assert(n1 == n2)
  end
  for j = 1, k:length() do
    local key = k:get_one(j-1)
    local is_found, oldval = A:del1(key)
    assert(is_found == true)
  end
  local M = A:meta()
  assert(M.nitems == 0)
  A:unset_produce()
  local outVs = A:set_produce(k)
  for j = 1, #vtypes do 
    local n1, n2 = Q.sum(Q.vveq(
      outVs[j], 
      Q.const({val = 0, len = k:length(), qtype = vtypes[j]}))):eval()
    assert(n1 == n2)
    
  end

  print("Success on test t2")
end
tests.t3 = function(m, n)
  local m = m or 1000000
  local n = n or (m*1000)
  print("m, n = ", m, n)
  --======================
  -- create an aggregator, should work
  local T1 = require 'Q/RUNTIME/MAGG/lua/test1'
  local A = lAggregator(T1, "libaggtest1")
  --======================
  local  k = Q.rand({ qtype = "I8", lb = 1, ub = m, len = n}):memo(false)
  local vtypes = { "F4", "I1", "I2", "I4" }
  local num_vals = #vtypes

  local v1 = Q.rand({ qtype = "F4", lb = 1, ub = 1000000, len = n})
  local v2 = Q.rand({ qtype = "I1", lb = -127, ub = 127, len = n})
  local v3 = Q.rand({ qtype = "I2", lb = -32767, ub = 32767, len = n})
  local v4 = Q.rand({ qtype = "I4", lb = 1, ub = 1000000, len = n})
  local vals = { v1, v2, v3, v4}
  for _, v in pairs(vals) do 
    v:memo(false)
  end
  assert(A:set_consume(k, vals))
  local num_chunks = 0
  repeat 
    local num_consumed = A:consume()
    num_chunks = num_chunks + 1
  until ( num_consumed == 0 )
  print("num_chunks, n = ", num_chunks, n)
  print("Success on test t3")
end
-- return tests
tests.t1()
tests.t2()
tests.t3(1000)
print("All done"); os.exit()
