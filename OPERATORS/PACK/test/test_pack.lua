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
  T1[#T1+1] = Q.period({start = 1, by = 1, period = 10, len = n, qtype = "I1", })
  T1[#T1+1] = Q.const({val = true, len = n, qtype = "BL", })

  local x = Q.pack(T1, "UI16")
  assert(type(x) == "lVector")
  assert(x:qtype() == "UI16")
  x:eval()
  assert(x:num_elements() == n)
  assert(x:width() == 16)

  -- test that x is correct. Use unpack for this 
  local T2 = Q.unpack(x, { "F8", "F4", "I2", "I1", "BL" })
  assert(type(T2) == "table")
  for k, _ in ipairs(T2) do 
    assert(type(T2[k]) == "lVector")
    assert(T2[k]:qtype() == T1[k]:qtype())
  end
  for k, _ in ipairs(T2) do 
    if ( k > 2 ) then
    local tmp = Q.vveq(T1[k], T2[k])
    local r = Q.sum(tmp)
    local n1, n2 = r:eval()
    Q.print_csv({T1[k], T2[k]}, { opfile = "_x.csv"})
    assert(n1 == n2)
    r:delete()
    tmp:delete()
    T1[k]:delete()
    T2[k]:delete()
  end
  end 
  local post = lgutils.mem_used()
  assert(pre == post)
  collectgarbage("restart")
end
-- return tests
tests.t1()
