require 'Q/UTILS/lua/strict'
local cutils = require 'libcutils'
local plpath = require 'pl.path'
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/qconsts'
local qmem    = require 'Q/UTILS/lua/qmem'
qmem.init()
local chunk_size = qmem.chunk_size
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local initialized = false
local function initialize()
 if ( initialized ) then return true end 
  --== cdef necessary stuff
  local for_cdef = require 'Q/UTILS/lua/for_cdef'
  
  local infile = "RUNTIME/CMEM/inc/cmem_struct.h"
  local incs = { "RUNTIME/CMEM/inc/", "UTILS/inc/" }
  local x = for_cdef(infile, incs)
  ffi.cdef(x)
  
  local infile = "RUNTIME/VCTR/inc/vctr_struct.h"
  local incs = { "RUNTIME/CMEM/inc/", "UTILS/inc/" }
  local x = for_cdef(infile, incs)
  ffi.cdef(x)
  initialized = true
end
--=================================
local tests = {}
-- testing put1 and get1 

tests.t0 = function(delta)
  initialize()
  local cdata = qmem.cdata(); 
  assert(type(cdata) == "CMEM")
  local g_S = ffi.cast("const qmem_struct_t *", cdata:data())
  -- delta allows us to test more than just multiple of chunk size 
  if ( not  delta ) then delta = 0 end 
  local qtype = "SC"
  local width = 4 -- remember 1 byte reserved for nullc
  local v = assert(cVector.new( { qtype = qtype, width = width}, cdata))
  v:memo(true)
  assert(v:is_memo() == true)
  --=============
  local n = chunk_size + delta 
  local exp_num_chunks = 0
  local exp_num_elements = 0
  -- put elements as 1, 2, 3, ...
  local s = assert(cmem.new({size =4, qtype = "SC"}))
  s:zero()
  ffi.cdef("char *strcpy(char *dest, const char *src);");
  local sp = ffi.cast("char *", get_ptr(s))
  for i = 1, n do 
        if ( ( i % 3 ) == 0 ) then ffi.C.strcpy(sp, "ABC") 
    elseif ( ( i % 3 ) == 1 ) then ffi.C.strcpy(sp, "DEF") 
    elseif ( ( i % 3 ) == 2 ) then ffi.C.strcpy(sp, "GHI") 
    else error("") end 
    assert(v:put1(s))
  end
  --================
  -- make sure you get what you put
  for i = 1, n do 
    local s = v:get1(i-1)
    assert(type(s) == "CMEM")
    local sp = ffi.cast("CMEM_REC_TYPE *", s)
    assert(sp.width == width)
    assert(ffi.string(sp.fldtype) == "SC")
    -- print(i, ffi.string(sp.data))
        if ( ( i % 3 ) == 0 ) then assert(ffi.string(sp.data) == "ABC")
    elseif ( ( i % 3 ) == 1 ) then assert(ffi.string(sp.data) == "DEF")
    elseif ( ( i % 3 ) == 2 ) then assert(ffi.string(sp.data) == "GHI")
    else error("") end 
    assert(s:fldtype() == "SC")
    -- TODO assert(s:to_num() == i, i)
  end
  --================
  v:persist()
  v:eov()
  local num_chunks=assert(ffi.cast("VEC_REC_TYPE *", v:me())[0].num_chunks)
  local x = v:shutdown() 
  assert(type(x) == "string") 
  assert(#x > 0)
  local y = loadstring(x)()
  assert(type(y) == "table")
  assert(y.num_elements == n)
  assert(y.width == width)
  local z = assert(cVector.reincarnate(y, cdata))
  assert(z:check())
  local M = assert(z:me())
  M = ffi.cast("VEC_REC_TYPE *", M)
  -- testing different style of access
  local x = "num_elements"
  assert(M[0][x] == n)
  --==========
  assert(M[0].num_elements == n)
  assert(M[0].field_width == width)
  assert(ffi.string(M[0].fldtype) == qtype)
  for i = 1, n do
    local s = z:get1(i-1)
    assert(type(s) == "CMEM")
    local sp = ffi.cast("CMEM_REC_TYPE *", s)
    assert(sp.width == width)
    assert(ffi.string(sp.fldtype) == "SC")
    assert(s:fldtype() == "SC")
        if ( ( i % 3 ) == 0 ) then assert(ffi.string(sp.data) == "ABC")
    elseif ( ( i % 3 ) == 1 ) then assert(ffi.string(sp.data) == "DEF")
    elseif ( ( i % 3 ) == 2 ) then assert(ffi.string(sp.data) == "GHI")
    else error("") end 
  end
  assert(z:check())

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
