-- FUNCTIONAL 
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local qcfg = require 'Q/UTILS/lua/qcfg'
local max_num_in_chunk = qcfg.max_num_in_chunk
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
  end
  print("Test t1 succeeded")
end
--=========================================
tests.t2 = function()
  local n = 1048576+17
  local y = Q.seq({start = 1, by = 1, qtype = "I4", len = n })
  assert(type(y) == "lVector")
  local z = Q.sum(y):eval():to_num()
  assert( z == (n * (n+1) / 2 ) )
  print("Test t2 succeeded")
end
--=========================================
tests.t3 = function()
  local n = max_num_in_chunk + 17
  
  local qtypes = { "BL", "B1", }
  for k, qtype in pairs(qtypes) do 
    local y = Q.const({val = true, qtype = qtype, len = n })
    local outval, outcnt = Q.sum(y):eval()
    print(outval, outcnt)
    assert(type(outval) == "Scalar")
    assert(outval:to_num() == n)

    assert(type(outcnt) == "Scalar")
    assert(outcnt:to_num() == n)
    
    print("Test t3 " .. qtype .. " succeeded")
  end
  print("Test t3 succeeded")
end
--=========================================
tests.t4 = function()
  local n = max_num_in_chunk * 2 + 3
  
  local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" } 
  for k, qtype in pairs(qtypes) do 
    local y = Q.const({val = 2, qtype = qtype, len = n })
    local outval, outcnt = Q.sum(y):eval()
    assert(type(outval) == "Scalar")
    assert(outval:to_num() == 2*n)

    assert(type(outcnt) == "Scalar")
    assert(outcnt:to_num() == n)
    
    print("Test t4, qtype =  " .. qtype .. " succeeded")
  end
  print("Test t4 succeeded")
end
--=========================================
--[[
return tests
os.exit()
--]]
-- TODO TODO tests.t1() -- Need Q.rand() to work 
tests.t2()
tests.t3() 
tests.t4()
os.exit()
