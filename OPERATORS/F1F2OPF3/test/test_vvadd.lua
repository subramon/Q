-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local Scalar  = require 'libsclr'
local plpath  = require 'pl.path'
local qcfg = require 'Q/UTILS/lua/qcfg'
local max_num_in_chunk  = qcfg.max_num_in_chunk
local lgutils = require 'liblgutils'

local tests = {}
tests.t1 = function()
  local optargs = { max_num_in_chunk  = 64 , }
  local ops = { "vvadd", "vvsub", "vvmul", "vvdiv", } 
  local len = 2 * optargs.max_num_in_chunk + 3
  for _, op in ipairs(ops) do
    local qtypes = { "I4", "I8", "F4", "F8", } 
    for _, qtype in pairs(qtypes) do
      local x1 = {}; for i = 1, len do x1[i] = i end
      local x2 = {}; for i = 1, len do x2[i] = 2*i+1 end
      local x3
      if ( op == "vvadd" ) then 
        x3 = {}; for i = 1, len do x3[i] = x1[i] + x2[i] end 
      elseif ( op == "vvsub" ) then 
        x3 = {}; for i = 1, len do x3[i] = x1[i] - x2[i] end 
      elseif ( op == "vvmul" ) then 
        x3 = {}; for i = 1, len do x3[i] = x1[i] * x2[i] end 
      elseif ( op == "vvdiv" ) then 
        x3 = {}; for i = 1, len do x3[i] = x1[i] / x2[i] end 
      else
        error("XXX")
      end
    
      if ( ( op == "vvdiv" ) and 
          ( qtype == "I4" ) or ( qtype == "I8" ) ) then 
        print("Test t1 skipped   for op = " .. op .. " and qtype = " .. qtype)
      else
        local c1 = Q.mk_col(x1, qtype, optargs)
        local c2 = Q.mk_col(x2, qtype, optargs)
        local c3 = Q.mk_col(x3, qtype, optargs)
        assert(c1:num_elements() == len)
        assert(c2:num_elements() == len)
        local z = Q[op](c1, c2):eval()
        for i = 1, len do 
          -- print(i)
          -- print(z:get1(i-1))
          -- print(c3:get1(i-1))
          -- NOTE: could not do following assert because of vvdiv
          -- precision issues
          -- assert(z:get1(i-1) == c3:get1(i-1))
          local diff = math.abs(z:get1(i-1):to_num() - c3:get1(i-1):to_num())
          assert(diff < 0.001)
        end
        print("Test t1 succeeded for op = " .. op .. " and qtype = " .. qtype)
        c1:delete()
        c2:delete()
        c3:delete()
        z:delete()
      end
    end
  end
  print("Test t1 succeeded")
end

tests.t2 = function()
  local optargs = { max_num_in_chunk  = 64 , }
  local qtypes = { "I4", "I8", "F4", "F8", } 
  for _, qtype in pairs(qtypes) do
    local input_table1 = {}
    local input_table2 = {}
    local expected_table = {}
    for i = 1, max_num_in_chunk + 7 do 
      input_table1[i] = i
      input_table2[i] = i * 10
      expected_table[i] = i + (i * 10)
    end
    local c1 = Q.mk_col(input_table1, qtype , optargs)
    local c2 = Q.mk_col(input_table2, qtype , optargs)
    local expected_col = Q.mk_col(expected_table, qtype , optargs)
    
    -- Perform vvadd
    local res = Q.vvadd(c1, c2):eval()
    
    -- Verification
    local x = Q.vvneq(res, expected_col):eval()
    local y = Q.sum(x)
    assert(type(y) == "Reducer")
    local n1, n2 = y:eval()
    assert(n1:to_num() == 0)
    c1:delete()
    c2:delete()
    expected_col:delete()
    res:delete()
    x:delete()
    assert(y:delete())
    collectgarbage()
    print("Test t2 succeeded for qtype", qtype)
  end
  print("Test t2 succeeded")
end
-- tests.t1()
tests.t2()
collectgarbage()
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))

-- return tests
