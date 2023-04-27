-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qcfg = require 'Q/UTILS/lua/qcfg'
local max_num_in_chunk = qcfg.max_num_in_chunk
local cVector = require 'libvctr'
local lgutils = require 'liblgutils'
local tests = {}
--=========================================
tests.t1 = function()
  for iter = 1, 100 do 
    local x = Q.rand( { lb = 0, ub = 1, qtype = "F8", len = 65537 } )
    assert(type(x) == "lVector")
    assert(x:qtype() == "F8")
    local y = Q.sum(x)
    assert(type(y) == "Reducer")
    local n, m = y:eval()
    assert(type(n) == "Scalar")
    assert(n:qtype() == "F8")
    assert(m:qtype() == "I8")
    x:delete()
    y:delete()
  end
  assert(cVector.check_all())
  print("Test t1 succeeded")
end
--=========================================
tests.t2 = function()
  local n = 1048576+17
  local y = Q.seq({start = 1, by = 1, qtype = "I4", len = n })
  assert(type(y) == "lVector")
  local r = Q.sum(y)
  local z = r:eval():to_num()
  assert( z == (n * (n+1) / 2 ) )
  assert(cVector.check_all())
  y:delete()
  r:delete()
  print("Test t2 succeeded")
end
--=========================================
tests.t3 = function()
  local n = max_num_in_chunk + 17
  
  local qtypes = { "BL", "B1", }
  for k, qtype in pairs(qtypes) do 
    print("PRE MEM", k, qtype, lgutils.mem_used())
    local y = Q.const({val = true, qtype = qtype, len = n })
    local r = Q.sum(y)
    local outval, outcnt = r:eval()
    -- print(outval, outcnt)
    assert(type(outval) == "Scalar")
    assert(outval:to_num() == n)

    assert(type(outcnt) == "Scalar")
    assert(outcnt:to_num() == n)
    
    y:delete()
    r:delete()
    print("Test t3 " .. qtype .. " succeeded")
    print("POS MEM", k, qtype, lgutils.mem_used())
  end
  assert(cVector.check_all())
  print("Test t3 succeeded")
end
--=========================================
tests.t4 = function()
  local n = max_num_in_chunk * 2 + 3
  
  local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" } 
  for k, qtype in pairs(qtypes) do 
    local y = Q.const({val = 2, qtype = qtype, len = n })
    local r = Q.sum(y)
    local outval, outcnt = r:eval()
    assert(type(outval) == "Scalar")
    assert(outval:to_num() == 2*n)

    assert(type(outcnt) == "Scalar")
    assert(outcnt:to_num() == n)
    
    y:delete()
    r:delete()
    print("Test t4, qtype =  " .. qtype .. " succeeded")
  end
  assert(cVector.check_all())
  print("Test t4 succeeded")
end
--=========================================
--[[
return tests
os.exit()
--]]
-- TODO TODO tests.t1() -- Need Q.rand() to work 
tests.t2()
-- tests.t3() 
tests.t4()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
