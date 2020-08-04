require 'Q/UTILS/lua/strict'
local cutils = require 'libcutils'
local plpath = require 'pl.path'
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local function initialize()
--== cdef necessary stuff
local for_cdef = require 'Q/UTILS/lua/for_cdef'

local infile = "RUNTIME/CMEM/inc/cmem_struct.h"
local incs = { "UTILS/inc/" }
local x = for_cdef(infile, incs)
ffi.cdef(x)

local infile = "RUNTIME/VCTR/inc/core_vec_struct.h"
local incs = { "UTILS/inc/" }
local x = for_cdef(infile, incs)
ffi.cdef(x)
end
--=================================
local chunk_size = 65536
local params = { chunk_size = chunk_size, sz_chunk_dir = 4096, 
    data_dir = qconsts.Q_DATA_DIR }
cVector.init_globals(params)
--=================================
local tests = {}
-- testing put1 and get1 

tests.t0 = function(delta)
  initialize()
  -- delta allows us to test more than just multiple of chunk size 
  if ( not  delta ) then delta = 0 end 
  local qtype = "SC"
  local width = 4 -- remember 1 byte reserved for nullc
  local v = cVector.new( { qtype = qtype, width = width} )
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
  assert(ffi.cast("VEC_REC_TYPE *", v:me())[0].is_dead)
  assert(type(x) == "string") 
  assert(#x > 0)
  local y = loadstring(x)()
  assert(type(y) == "table")
  assert(y.num_elements == n)
  assert(y.width == width)
  local z = assert(cVector.rehydrate(y))
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
  z:check()
  cVector:check_chunks()

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
