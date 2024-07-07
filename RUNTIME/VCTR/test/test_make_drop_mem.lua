local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local lgutils = require 'liblgutils'

local qtype = "I4"
local max_num_in_chunk = 64
local len = 3 * max_num_in_chunk + 7
local num_chunks = math.ceil(len/max_num_in_chunk)

local tests = {}
tests.t1 = function()
  collectgarbage("stop")
  local pre_mem = lgutils.mem_used()
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = qtype, 
    name = "test1_x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  x1:eval()
  local chunk_size = x1:max_num_in_chunk() * x1:width()
  local init_mem_used = lgutils.mem_used()
  local init_dsk_used = lgutils.dsk_used()
  assert(init_dsk_used == 0)

  local niters  = 10
  for i  = 1, niters do 
    x1:make_mem(2)
    x1:drop_mem(1)
    local dsk = lgutils.dsk_used() 
    local mem = lgutils.mem_used()
    print("mem/dsk = ", mem, dsk)
    assert(lgutils.dsk_used() == init_mem_used)
    assert(lgutils.mem_used() == 0)
    x1:make_mem(1)
    x1:drop_mem(2)
  end
  assert(cVector.check_all())
  x1 = nil; collectgarbage()
  local post_mem = lgutils.mem_used()
  assert(pre_mem == post_mem)
  print("Test t1 succeeded")
end
tests.t2 = function()
  collectgarbage("stop")
  local pre_mem = lgutils.mem_used()
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = qtype, 
    name = "test1_x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  x1:eval()
  local chunk_size = x1:max_num_in_chunk() * x1:width()
  local init_mem_used = lgutils.mem_used()
  local chk_mem_used = init_mem_used
  local init_dsk_used = lgutils.dsk_used()
  local chk_dsk_used = init_dsk_used
  assert(init_dsk_used == 0)

  for j = 1, num_chunks do 
    x1:make_mem(2, j-1)
    x1:drop_mem(1, j-1)
    chk_mem_used = chk_mem_used - chunk_size
    chk_dsk_used = chk_dsk_used + chunk_size
    assert(lgutils.mem_used() == chk_mem_used)
    assert(lgutils.dsk_used() == chk_dsk_used)
  end
  for j = 1, num_chunks do 
    x1:make_mem(1, j-1)
    x1:drop_mem(2, j-1)
    chk_mem_used = chk_mem_used + chunk_size
    chk_dsk_used = chk_dsk_used - chunk_size
    assert(lgutils.mem_used() == chk_mem_used)
    assert(lgutils.dsk_used() == chk_dsk_used)
  end

  x1 = nil; collectgarbage()
  local post_mem = lgutils.mem_used()
  assert(pre_mem == post_mem)
  assert(cVector.check_all())
  print("Test t2 succeeded")
end
collectgarbage()
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
tests.t1()
tests.t2()
