local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local lgutils = require 'liblgutils'

local qtype = "I4"
local max_num_in_chunk = 64
local len = 3 * max_num_in_chunk + 7
local tests = {}
tests.t1 = function()
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = qtype, 
    name = "test1_x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  x1:eval()
  local num_chunks = math.ceil(len/max_num_in_chunk)
  local chunk_size = x1:max_num_in_chunk() * x1:width()
  local niters  = 1 
  for i  = 1, niters do 
    local mem_used = lgutils.mem_used()
    for j = 1, num_chunks do 
      local exists = x1:prefetch(j-1)
      assert(exists == true)
      assert(mem_used == lgutils.mem_used())
    end
    print("Finished prefetch of all chunks")
    -- now free all l1 mem 
    for j = 1, num_chunks do 
      x1:unprefetch(j-1) 
      mem_used = mem_used - chunk_size
      assert(mem_used == lgutils.mem_used())
    end
    assert(lgutils.mem_used() == 0)
    print("Finished unprefetch of all chunks")
    -- this is what happens when you ask for a chunk that isn't there
    local exists = x1:prefetch(num_chunks) 
    assert(exists == false)
    exists = x1:prefetch(-1)
    assert(exists == false)
  end
  x1 = nil; collectgarbage()
  assert(cVector.check_all())
  print("Test t1 succeeded")
end
collectgarbage()
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
tests.t1()
