local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
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
tests.t_clone = function()
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local x = Q.seq({ len = len, start = 1, by = 1, qtype = qtype, 
    name = "test0_x", max_num_in_chunk = max_num_in_chunk, memo_len = -1 })
  x:eval()
  x:chunks_to_lma()
  local y = x:clone()
  y:check()
  local z = Q.vveq(x, y)
  local r = Q.sum(z)
  local n1, n2 = r:eval()
  assert(n1 == n2)
  x:delete()
  y:delete()
  z:delete()
  r:delete()
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  collectgarbage("restart")
  print("Test t_clone completed successfully")
end
-- return tests
tests.t_clone()
