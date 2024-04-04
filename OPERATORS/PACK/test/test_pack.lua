local Q       = require 'Q'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local lgutils = require 'liblgutils'
local cutils  = require 'libcutils'
local tests = {}
-- The test is repeated 3 times.
-- iter == 1 creates UI2
-- iter == 2 creates UI4
-- iter == 3 creates UI8
-- iter == 4 creates UI16
tests.t1 = function()
  collectgarbage(); collectgarbage("stop")
  local pre = lgutils.mem_used()
  local n = 2 * qcfg.max_num_in_chunk + 17 
  local niter = 3
  local unpack_qtypes 
  for iter = 1, niter do 
    local out_qtype
    if ( iter == 1 ) then
      out_qtype = "UI2"
      unpack_qtypes = { "F8", "F4", "I2", "I1", "BL" }
      unpack_qtypes = { "I1", "BL" }
    elseif ( iter == 2 ) then
      out_qtype = "UI4"
      unpack_qtypes = { "I2", "I1", "BL" }
    elseif ( iter == 3 ) then
      out_qtype = "UI8"
      unpack_qtypes = { "F4", "I2", "I1", "BL" }
    elseif ( iter == 4 ) then
      out_qtype = "UI16"
      unpack_qtypes = { "F8", "F4", "I2", "I1", "BL" }
    else
      error("")
    end

    local T1 = {}
    if ( iter >= 4 ) then 
      T1[#T1+1] = Q.seq({start = 1000, by = 1000, len = n, qtype = "F8", })
    end
    if ( iter >= 3 ) then 
      T1[#T1+1] = Q.seq({start = 100, by = 100, len = n, qtype = "F4", })
    end
    if ( iter >= 2 ) then 
      T1[#T1+1] = Q.period({start = 10, by = 10, period = 100, len = n, qtype = "I2", })
    end
    T1[#T1+1] = Q.period({start = 1, by = 1, period = 10, len = n, qtype = "I1", })
    T1[#T1+1] = Q.const({val = true, len = n, qtype = "BL", })
  
    local x = Q.pack(T1, out_qtype)
    assert(type(x) == "lVector")
    assert(x:qtype() == out_qtype)
    x:eval()
    assert(x:num_elements() == n)
    assert(x:width() == cutils.get_width_qtype(out_qtype))
  
    -- test that x is correct. Use unpack for this 
    local T2 = Q.unpack(x, unpack_qytpes)
    assert(type(T2) == "table")
    for k, _ in ipairs(T2) do 
      assert(type(T2[k]) == "lVector")
      assert(T2[k]:qtype() == T1[k]:qtype())
    end
    for k, _ in ipairs(T2) do 
      local tmp = Q.vveq(T1[k], T2[k])
      local r = Q.sum(tmp)
      local n1, n2 = r:eval()
      -- Q.print_csv({T1[k], T2[k]}, { opfile = "_x.csv"})
      assert(n1 == n2)
      r:delete()
      tmp:delete()
      T1[k]:delete()
      T2[k]:delete()
    end 
    local post = lgutils.mem_used()
    assert(pre == post)
    collectgarbage("restart")
    print("Completed iteration " .. iter .. " of test t1()")
  end
  print("Completed test t1() successfully")
end
-- return tests
tests.t1()
