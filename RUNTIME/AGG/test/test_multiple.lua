local lAggregator = require 'Q/RUNTIME/AGG/lua/lAggregator'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Scalar = require 'libsclr'
local lVector = require 'libvec'
local Q = require 'Q'
local tests = {}
tests.t1 = function()
  -- testing putn()
  local params = { keytype = "I4", valtype = "F4"}
  local chunk_size = qconsts.chunk_size
  n = chunk_size* 16  --- must be me a multiple of chunk size for this test
  local A = lAggregator(params)
  local K = Q.seq({start = 1, by = 1, qtype = "I4", len = n})
  local V = Q.seq({start = 1, by = 1, qtype = "F4", len = n})
  assert(type(K) == "lVector")
  assert(type(V) == "lVector")
  assert(A:set_consume(K, V))
  assert(not A:is_clean())
  local iters = 0
  local nitems = 0
  local iter = 1
  --==================================
  repeat 
    local x =  A:consume()
    iters = iters + 1 
    nitems = nitems + x
    assert( ( x == 0 ) or ( x == chunk_size ) ) 
    local M = A:get_meta()
    assert(M.nitems == nitems)
  until ( x == 0 )
  assert(nitems == n)
  local M = A:get_meta()
  assert(M.nitems == n)
  assert(A:is_clean())
  --==================================
  -- Repeat same thing with same keys, should see no change in nitems
  -- --[[
  local K2 = Q.seq({start = 1, by = 1, qtype = "I4", len = n})
  local V2 = Q.const({ val = 100, qtype = "F4", len = n})
  local x = A:set_consume(K2, V2)
  assert(x, "cannot set_consume because agg is not clean")
  repeat 
    local x =  A:consume()
    local M = A:get_meta()
    assert(M.nitems == n)
  until ( x == 0 )
  --=========================
  print("Success on test t1")
end
tests.t2 = function()
  -- testing putn()
  local status
  local params = { keytype = "I4", valtype = "F4"}
  local chunk_size = qconsts.chunk_size
  n = chunk_size* 16  --- must be me a multiple of chunk size for this test
  local A = lAggregator(params)
  local K = Q.seq({start = 1, by = 1, qtype = "I4", len = n})
  local V = Q.seq({start = 1, by = 1, qtype = "F4", len = n})
  status = A:set_consume(K, V)
  assert(status)
  status = A:set_consume(K, V)
  assert(not status)
  status = A:unset_consume()
  assert(status)
  status = A:set_consume(K, V)
  assert(status)
  --=========================
  print("Success on test t2")
end
tests.t3 = function()
  -- testing getn()
  local status
  local params = { keytype = "I4", valtype = "F4"}
  local chunk_size = qconsts.chunk_size
  n = chunk_size* 16  --- must be me a multiple of chunk size for this test
  local A = lAggregator(params)
  local K = Q.seq({start = 1, by = 1, qtype = "I4", len = n})
  local V = Q.seq({start = 1, by = 1, qtype = "F4", len = n})
  status = A:set_consume(K, V)
  A:consume()
  -- Now let's do a getn
  len2 = 16 
  local K2 = Q.seq({start = 1, by = 1, qtype = "I4", len = len2})
  local chk_V2 = Q.seq({start = 1, by = 1, qtype = "F4", len = len2})
  local V2 = A:set_produce(K2)
  assert(type(V2) == "lVector")
  local x, y = V2:chunk(0)
  assert(x == len2, "x = " .. x )
  assert(V2:is_eov())
  local n1, n2 = Q.sum(Q.vvneq(chk_V2, V2)):eval()
  assert(n1:to_num() == 0)
  assert(n2:to_num() == len2)
  --=========================
  print("Success on test t3")
end
-- TODO P2 Write more tests for getn
return tests
