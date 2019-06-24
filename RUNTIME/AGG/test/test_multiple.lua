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
  assert(A:set_in(K, V))
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
  assert(A:set_in(K2, V2))
  repeat 
    local x =  A:step()
    local M = A:get_meta()
    assert(M.nitems == n)
  until ( x == 0 )
  --=========================
  print("Success on test t1")
end
return tests
