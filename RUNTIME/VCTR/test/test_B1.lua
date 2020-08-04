require 'Q/UTILS/lua/strict'
local cutils = require 'libcutils'
local plpath = require 'pl.path'
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
--== cdef necessary stuff
local for_cdef = require 'Q/UTILS/lua/for_cdef'

local function initialize()
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
--=================================
local chunk_size = 65536
local params = { chunk_size = chunk_size, sz_chunk_dir = 4096, 
    data_dir = qconsts.Q_DATA_DIR }
cVector.init_globals(params)
--=================================
local tests = {}
-- testing put1 and get1 for B1

tests.t0 = function(incr)
  initialize()
  if ( not  incr ) then incr = 0 end 
  local qtype = "B1"
  local width = 1
  local v = cVector.new( { qtype = qtype, width = width } )
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
  end
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
  end
  --================
  v:persist()
  v:eov()
  v:check()
  cVector:check_chunks()
  local num_chunks=assert(ffi.cast("VEC_REC_TYPE *", v:me())[0].num_chunks)
  local x = v:shutdown() 
  -- assert(v:is_dead())
  -- TODO THINK P3 assert(ffi.cast("VEC_REC_TYPE *", v:me())[0].is_dead)
  assert(type(x) == "string") 
  assert(#x > 0)
  local y = loadstring(x)()
  assert(type(y) == "table")
  assert(y.num_elements == n)
  assert(y.width == width)
  assert(y.qtype == qtype)
  -- print("incr/num_chunks = ", incr, num_chunks)
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

  local z = assert(cVector.rehydrate(y))
  print("Successfully rehydrated")
  local M = assert(z:me())
  M = ffi.cast("VEC_REC_TYPE *", M)
  assert(M[0].num_elements == n)
  assert(M[0].field_width == width)
  assert(ffi.string(M[0].fldtype) == qtype)
  local alternate = false
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
tests.t1() 
tests.t0() 
os.exit()
--]]
