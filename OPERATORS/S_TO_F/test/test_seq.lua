-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local qmem    = require 'Q/UTILS/lua/qmem'
local chunk_size = qmem.chunk_size
local tests = {}

tests.t1 = function()
  local csz = chunk_size
  local len = 2 * csz + 17
  local start = 1
  local by = 2
  local qtype = "I4"
  local c1 = Q.seq({ len = len, start = start, by = by, qtype = qtype})
  c1:eval()
  local val = start
  for i = 1, len do
    assert(c1:get1(i-1):to_num() == val)
    val = val + by
  end
  assert(c1:num_elements() == len)
  local status = pcall(c1.get1, len) -- deliberate error
  assert(not status)
  assert(c1:qtype() == qtype)
  print("Test t1 succeeded")
end
--[[
tests.t1()
os.exit()
--]]
return tests
