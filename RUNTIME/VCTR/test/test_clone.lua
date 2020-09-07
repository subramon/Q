require 'Q/UTILS/lua/strict'
local cutils = require 'libcutils'
local plpath = require 'pl.path'
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/qconsts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local pldir   = require 'pl.dir'

local tests = {}
lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
--=================================
local chunk_size = 65536
local params = { chunk_size = chunk_size, sz_chunk_dir = 4096, 
      data_dir = qconsts.Q_DATA_DIR }
cVector.init_globals(params)
assert(cVector.chunk_size() == chunk_size)
--=================================
-- testing put1 and get1 and clone 
tests.t1 = function()
  for _, qtype in ipairs({"I1","I2", "I4","I8", "F4", "F8"}) do 
    local width = qconsts.qtypes[qtype].width
    local v = lVector.new( { qtype = qtype, width = width} )
    
    local n = chunk_size + 3
    local val = 0
    for i = 1, n do 
      local s = Scalar.new(val, qtype)
      v:put1(s)
      val = val + 1
      if ( val == 50 ) then val = 0 end 
    end
    -- cannot clone until eov tru 
    local status, msg = pcall(v.clone, v)
    assert(not status)
    ----
    v:eov()
    local w = v:clone()
    assert(w:is_eov())
    assert(type(w) == "lVector")
    for i = 1, n do 
      assert(w:get1(i-1) == v:get1(i-1))
    end
    -- Now modify the w vector by doubling every element 
    local chk_n, cmem, nn_cmem = w:start_write()
    assert(n == chk_n)
    local cptr = get_ptr(cmem, qtype)
    for i = 1, n do 
      cptr[i-1] = 2 * cptr[i-1]
    end
    w:end_write()
    -- Now confirm that w vector is twice the v vector 
    for i = 1, n do 
      local w1 = w:get1(i-1)
      local v1 = v:get1(i-1)
      local v2 = Scalar.new(2) * v1
      assert(w1 == v2)
    end
  end
  print("Test t1 completed")
end
-- testing shutdown before eov => deletion of vector
tests.t2 = function()
  for _, qtype in ipairs({"I1","I2", "I4","I8", "F4", "F8"}) do 
    local width = qconsts.qtypes[qtype].width
    local v = lVector.new( { qtype = qtype, width = width} )
    local n = chunk_size + 3
    for i = 1, n do 
      local s = Scalar.new(1, qtype)
      v:put1(s)
    end
    local x = v:shutdown()
    assert(not x)
  end
  print("Test t2 completed")
end
-- testing shutdown after eov but no persist => deletion of vector 
tests.t3 = function()
  for _, qtype in ipairs({"I1","I2", "I4","I8", "F4", "F8"}) do 
    local width = qconsts.qtypes[qtype].width
    local v = lVector.new( { qtype = qtype, width = width} ):persist(false)
    local n = chunk_size + 3
    for i = 1, n do 
      local s = Scalar.new(1, qtype)
      v:put1(s)
    end
    v:eov()
    local x = v:shutdown()
    assert(not x)
  end
  print("Test t3 completed")
end
-- testing shutdown after eov but no persist => reincarnate string returned
tests.t4 = function()
  for _, qtype in ipairs({"I1","I2", "I4","I8", "F4", "F8"}) do 
    local width = qconsts.qtypes[qtype].width
    local v = lVector.new( { qtype = qtype, width = width} ):persist(true)
    local n = chunk_size + 3
    for i = 1, n do 
      local s = Scalar.new(1, qtype)
      v:put1(s)
    end
    v:eov()
    local x = v:shutdown()
    assert(type(x) == "string")
    local y = loadstring(x)()
    local w = lVector(y)
    assert(type(w) == "lVector")
  end
  print("Test t4 completed")
end
return tests
