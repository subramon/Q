-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local qcfg   = require 'Q/UTILS/lua/qcfg'
local Scalar = require 'libsclr'
local cVector = require 'libvctr'
local lgutils = require 'liblgutils'

local blksz = qcfg.max_num_in_chunk 
local tests = {}
tests.t1 = function()
  local csz = blksz
  local len = 2 * csz + 17
  local start = 10
  local by = 20
  local qtype = "I4"
  local c1 = Q.seq({ len = len, start = start, by = by, qtype = qtype})
  c1:eval()
  local val = start
  for i = 1, len do
    assert(c1:get1(i-1) == Scalar.new(val, qtype))
    val = val + by
  end
  assert(c1:num_elements() == len)
  local status = pcall(c1.get1, len) -- deliberate error
  assert(not status)
  assert(c1:qtype() == qtype)
  assert(cVector.check_all())
  print("Test t1 succeeded")
end
tests.t1()
collectgarbage()
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
--[[
os.exit()
return tests
--]]
