local Q       = require 'Q'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local lgutils = require 'liblgutils'
local tests = {}
tests.t1 = function()
  collectgarbage(); collectgarbage("stop")
  local pre = lgutils.mem_used()
  local n = 2 * qcfg.max_num_in_chunk + 17 
  local T1 = {}
  T1[#T1+1] = Q.seq({start = 1000, by = 1000, len = n, qtype = "F8", })
  T1[#T1+1] = Q.seq({start = 100, by = 100, len = n, qtype = "F4", })
  T1[#T1+1] = Q.period({start = 10, by = 10, period = 100, len = n, qtype = "I2", })
  T1[#T1+1] = Q.period({start = 1, by = 1, period = 10, len = len, n = "I1", })
  T1[#T1+1] = Q.const({val = true, len = len, qtype = "BL", })

  local x = Q.pack(T1, "UI16")
  assert(type(x) == "lVector")
  assert(x:qtype() == "UI16")
  -- test that x is correct. Use unpack for this 
  local T2 = Q.unpack(x, { "F8", "F4", "I2", "I1", "BL" })
  assert(type(T2) == "table")
  for k, _ in ipairs(T2) do 
    local tmp = Q.vveq(T1[k], T2[k])
    local r = Q.sum(tmp)
    local n1, n2 = r:eval()
    assert(n1 == n2)
    r:delete()
    tmp:delete()
    T1[k]:delete()
    T2[k]:delete()
  end 
  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
end
-- return tests
tests.t1()
