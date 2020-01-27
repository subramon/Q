-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local tests = {}
tests.t1 = function()
  local n
  n = 67
  n = 32768
  n = 32768+10923
  print("n = ", n)
  local len = n * 3 
  local start = 1
  local by = 2
  local period = 3
  local y = Q.period({start = start, by = by, period = period, qtype = "I4", len = len })
  local val = start
  local cnt = 0
  for i = 1, len do
    assert(c1:get_one(i-1):to_num() == val)
    val = val + by
    cnt = cnt + 1 
    if ( cnt == period ) then val = start end 
  end
  print("successfully executed t1")
end
tests.t1()
-- return tests
