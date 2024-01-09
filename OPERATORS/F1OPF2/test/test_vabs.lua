require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local lgutils = require 'liblgutils'
local cVector = require 'libvctr'
local qcfg    = require 'Q/UTILS/lua/qcfg'

local tests = {}
tests.t1 = function()
  collectgarbage("stop")
  local pre = lgutils.mem_used()
  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8", }) do 
    local len 
    if ( qtype == "I1" ) then
      len = 127
    elseif ( qtype == "I2" ) then
      len = 32767
    else
      len = qcfg.max_num_in_chunk
    end
    local start = math.floor(-1.0 * len/2)
    local x = Q.seq({start = start, by = 1, len = len, qtype = qtype}):set_name("x")
    local y = Q.vabs(x):set_name("y")
    local z = Q.vsgeq(y, 0):set_name("z")
    local r = Q.sum(z)
    local n1, n2 = r:eval()
    assert(n1 == n2)

    x:delete()
    y:delete()
    z:delete()
    r:delete()
    local post = lgutils.mem_used()
    print(pre, post)
    -- cVector.hogs("mem")
    -- assert(pre == post) TODO P1 why is this leaking memory?
    collectgarbage("restart")
  end
  print("Test t1 succeeded")
end
tests.t1()
collectgarbage()
print("MEM", lgutils.mem_used())
-- return tests
