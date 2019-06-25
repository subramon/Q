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
  assert(A:set_key_val(K, V))
  local iters = 0
  local nitems = 0
  local iter = 1
  --==================================
  repeat 
    local x =  A:step()
    iters = iters + 1 
    nitems = nitems + x
    assert( ( x == 0 ) or ( x == chunk_size ) ) 
    local M = A:get_meta()
    assert(M.nitems == nitems)
  until ( x == 0 )
  assert(nitems == n)
  local M = A:get_meta()
  assert(M.nitems == n)
  --==================================
  -- Repeat same thing with same keys, should see no change in nitems
  -- --[[
  local K2 = Q.seq({start = 1, by = 1, qtype = "I4", len = n})
  local V2 = Q.const({ val = 100, qtype = "F4", len = n})
  assert(A:set_key_val(K2, V2))
  repeat 
    local x =  A:step()
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
  status = A:set_key_val(K, V)
  assert(status)
  status = A:set_key_val(K, V)
  assert(not status)
  status = A:unset_key_val()
  assert(status)
  status = A:set_key_val(K, V)
  assert(status)
  --=========================
  print("Success on test t2")
end
return tests
