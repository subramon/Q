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
local tests = {}
tests.t1 = function()
  local x1 = Q.seq({ len = len, start = 1, by = 1, qtype = qtype, 
    name = "test1_x1", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  x1:eval()
  local init_mem_used = lgutils.mem_used()
  local init_dsk_used = lgutils.dsk_used()

  local niters  = 10
  for i  = 1, niters do 
    for j = 1, 10 do 
      x1:drop_mem(1)
      print(i, j, lgutils.mem_used())
      assert(lgutils.mem_used() == 0)
      assert(lgutils.dsk_used() == init_dsk_used)
    end
  end
  x1 = nil; collectgarbage()
  assert(cVector.check_all())
  print("Test t1 succeeded")
end
collectgarbage()
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
tests.t1()
