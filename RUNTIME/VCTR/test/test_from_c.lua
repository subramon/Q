local ffi     = require 'ffi'
local lVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local clean_defs = require 'Q/RUNTIME/VCTR/test/clean_defs'

local hdrs = clean_defs("../inc/core_vec_struct.h", " -I../../../UTILS/inc/")
ffi.cdef(hdrs)
local tests = {}
tests.t1 = function()
  local qtype = "F4"
  local width = qconsts.qtypes[qtype].width
  local v = lVector.new(qtype, width);
  print(">>> start deliberate error")
  assert( not  v:get1(0))
  assert( not  v:get1(-1))
  assert( not  v:get1(1))
  print(">>>  stop deliberate error")
  local M = assert(v:me())
  M = ffi.cast("VEC_REC_TYPE *", M)
  assert(M[0].num_elements == 0)
  assert(v:memo(true))
  assert(v:memo(false))
  
  for i = 1, 1000000 do 
    local s = Scalar.new(i, "F4")
    v:put1(s)
    if ( i == 1 ) then 
      print(">>> start deliberate error")
      print( v:memo(true)) 
      assert( not v:memo(true)) 
      print(">>>  stop deliberate error")
    end
    local M = assert(v:me())
    M = ffi.cast("VEC_REC_TYPE *", M)
    assert(M[0].num_elements == i, "failed at " .. i)
  end
  for i = 1, 1000000 do 
    local s = v:get1(i-1)
    assert(type(s) == "Scalar")
    assert(s:fldtype() == "F4")
    assert(s:to_num() == i)
  end
  -- lVector:print_timers()
  lVector:reset_timers()
  print("Successfully completed test t1")
end
tests.t2 = function()
  local qtype = "I4"
  local width = qconsts.qtypes[qtype].width
  local v = lVector.new(qtype, width);
  
  local chunk_size = 65536 -- NOTE: this has to be in sync with C
  local num_chunks = 1024
  local D = cmem.new(chunk_size * width, "I4")
  for i = 1, num_chunks do 
    local Dptr = get_ptr(D, "F4")
    local offset = num_chunks * chunk_size
    for i = 1, chunk_size do
      Dptr[i-1] = offset + i
    end
    v:put_chunk(D)
    local M = assert(v:me())
    M = ffi.cast("VEC_REC_TYPE *", M)
    assert(M[0].num_elements == i*chunk_size, "failed at " .. i)
  end
  local M = assert(v:me())
  M = ffi.cast("VEC_REC_TYPE *", M)
  -- print("num_elements = ", M[0].num_elements)
  -- print("num_chunks = ",   M[0].num_chunks)
  assert(M[0].num_chunks == num_chunks)
  --[[
  for i = 1, num_chunks do 
    local s = v:get_chunk(i-1)
    assert(type(s) == "CMEM")
    assert(s:fldtype() == "F4")
  end
  --]]
  print("Successfully completed test t2")
end
-- return tests
-- tests.t1()
tests.t2()

