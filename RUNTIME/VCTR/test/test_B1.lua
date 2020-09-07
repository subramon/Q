require 'Q/UTILS/lua/strict'
local cutils = require 'libcutils'
local plpath = require 'pl.path'
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qmem    = require 'Q/UTILS/lua/qmem'
qmem.init()
local chunk_size = qmem.chunk_size
local qconsts = require 'Q/UTILS/lua/qconsts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
--== cdef necessary stuff
local for_cdef = require 'Q/UTILS/lua/for_cdef'

local initialized = false
local function initialize()
  if ( initialized ) then return true end 
  local infile = "RUNTIME/CMEM/inc/cmem_struct.h"
  local incs = { "UTILS/inc/" }
  local x = for_cdef(infile, incs)
  ffi.cdef(x)
  
  local infile = "RUNTIME/VCTR/inc/vctr_struct.h"
  local incs = { "UTILS/inc/" }
  local x = for_cdef(infile, incs)
  ffi.cdef(x)
  initialized = true 
  return true
end
--=================================
local tests = {}
-- testing put1 and get1 for B1

tests.t0 = function(incr)
  initialize()
  if ( not  incr ) then incr = 0 end 
  local qtype = "B1"
  local width = 1
  local cdata = qmem.cdata(); assert(type(cdata) == "CMEM")
  local g_S = ffi.cast("const qmem_struct_t *", cdata:data())
  
  --[[
  print(g_S)
  print(g_S[0].max_mem_KB)
  print(g_S[0].now_mem_KB)
  print(ffi.string(g_S[0].q_data_dir))
  print("n  = ", g_S[0].chunk_dir[0].n)
  print("sz = ", g_S[0].chunk_dir[0].sz)
  print("n  = ", g_S[0].whole_vec_dir[0].n)
  print("sz = ", g_S[0].whole_vec_dir[0].sz)
  --]]

  local v = assert(cVector.new({ qtype = qtype, width = width }, cdata))
  v:memo(true)
  --=============
  local n = chunk_size + incr
  local exp_num_chunks = 0
  local exp_num_elements = 0
  -- put elements alternating between true and false
  local s0 = Scalar.new(0, "B1")
  local s1 = Scalar.new(1, "B1")
  local alternate = false
  for i = 1, n do 
    if ( alternate == true ) then 
      assert(v:put1(s1))
      alternate = false
    else 
      assert(v:put1(s0))
      alternate = true
    end
    assert(v:check())
    -- print("Iter ", i)
  end
  assert(cVector.check_qmem(cdata))
  print("Finished puts, now getting")
  --================
  -- make sure you get what you put
  local alternate = false
  for i = 1, n do 
    local s = v:get1(i-1)
    assert(type(s) == "Scalar")
    assert(s:fldtype() == "B1")
    if ( alternate == true ) then 
      assert(s == s1)
      alternate = false
    else 
      assert(s == s0)
      alternate = true
    end
    assert(v:check())
  end
  assert(cVector.check_qmem(cdata))
  --================
  v:persist()
  v:eov()
  assert(v:check())
  local x = v:shutdown() 
  -- assert(v:is_dead())
  assert(type(x) == "string") 
  assert(#x > 0)
  local y = loadstring(x)()
  assert(type(y) == "table")
  assert(y.num_elements == n)
  assert(y.width == width)
  assert(y.qtype == qtype)
  assert(type(y.chunk_uqids) == "table")
  for _, v in ipairs(y.chunk_uqids) do
    assert(type(v) == "number")
    assert(v > 0)
  end 
  for k1, v1 in ipairs(y.chunk_uqids) do
    for k2, v2 in ipairs(y.chunk_uqids) do
      if ( k1 ~= k2 ) then assert(v1 ~= v2) end 
    end
  end 
  if ( incr > 0 ) then 
    assert(#y.chunk_uqids > 1 ) 
  else
    assert(#y.chunk_uqids == 1 ) 
  end

  local z = assert(cVector.reincarnate(y, cdata))
  assert(z:check())
  print("Successfully reincarnated")
  local M = assert(z:me())
  M = ffi.cast("VEC_REC_TYPE *", M)
  assert(M[0].num_elements == n)
  assert(M[0].field_width == width)
  assert(ffi.string(M[0].fldtype) == qtype)
  local alternate = false
  print("Gets starting")
  z:nop() -- for debugging 

  for i = 1, n do
    local s = z:get1(i-1)
    assert(type(s) == "Scalar")
    if ( alternate == true ) then 
      assert(s == s1)
      alternate = false
    else 
      assert(s == s0)
      alternate = true
    end
  end
  z:check()

  print("Successfully completed test t0 with n = ", n )
  return true
end

tests.t1 = function()
  assert(tests.t0(-1))
  print("Successfully completed test t1")
end
tests.t2 = function()
  assert(tests.t0(1))
  print("Successfully completed test t2")
end
return tests
--[[
tests.t0() 
tests.t1() 
os.exit()
--]]
