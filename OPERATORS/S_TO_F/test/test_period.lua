-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local lgutils = require 'liblgutils'

local blksz = qcfg.max_num_in_chunk 
local tests = {}
tests.t1 = function()
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local len = blksz * 7 + 19 
  local start  = 1
  local by     = 2
  local period = 3
  local qtype  = "I4"
  local args = {
    len = len, 
    start = start, by = by, 
    period = period, 
    qtype = qtype}

  local c1 = Q.period(args):eval()
  local val = start
  local cnt = 0
  for i = 1, len do
    assert(c1:get1(i-1):to_num() == val)
    assert(c1:get1(i-1) == Scalar.new(val, qtype))
    val = val + by
    cnt = cnt + 1 
    if ( cnt == period ) then val = start; cnt = 0 end 
  end
  assert(cVector.check_all())
  c1:delete()
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  collectgarbage("restart")
  print("successfully executed t1")
end
tests.t1()
--[[
return tests
os.exit()
--]]
