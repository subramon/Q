-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local cVector = require 'libvctr'
local tests = {}
tests.t1 = function()
  local len = cVector.chunk_size() * 7 + 19 
  local start  = 1
  local by     = 2
  local period = 3
  local qtype  = "I4"
  local c1 = Q.period(
  {len = len, start = start, by = by, period = period, qtype = qtype})
  c1:eval()
  local val = start
  local cnt = 0
  for i = 1, len do
    assert(c1:get1(i-1):to_num() == val)
    val = val + by
    cnt = cnt + 1 
    if ( cnt == period ) then val = start; cnt = 0 end 
  end
  print("successfully executed t1")
end
--[[
tests.t1()
os.exit()
--]]
return tests
