local plpath = require 'pl.path'
local ffi     = require 'ffi'
local lVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local clean_defs = require 'Q/UTILS/build/clean_defs'

local hdrs = clean_defs("../inc/core_vec_struct.h", " -I../../../UTILS/inc/")
ffi.cdef(hdrs)
local tests = {}
-- testing put1 and get1 
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
  
  -- test is currently a bit brittle
  -- some asserts rely on n=1000000 and chunk_size=65536
  local n = 1000000
  for i = 1, n do 
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
  for i = 1, n do 
    local s = v:get1(i-1)
    assert(type(s) == "Scalar")
    assert(s:fldtype() == "F4")
    assert(s:to_num() == i)
  end
  local M, C = assert(v:me())
  M = ffi.cast("VEC_REC_TYPE *", M)
  assert(type(C) == "table")
  for i = 1, #C do
    local chunk = ffi.cast("CHUNK_REC_TYPE *", C[i])
    -- dependent on n = 1000000 and chunk_size = 65536
    if ( i == 16 ) then
      assert(chunk[0].num_in_chunk == 16960)
    else 
      assert(chunk[0].num_in_chunk == 65536)
    end
  end
  -- lVector:print_timers()
  lVector:reset_timers()
  print("Successfully completed test t1")
end
-- testing put_chunk and get_chunk
tests.t2 = function()
  local qtype = "I4"
  local width = qconsts.qtypes[qtype].width
  local v = lVector.new(qtype, width);
  
  local chunk_size = qconsts.chunk_size

  local num_chunks = 1024
  local D = cmem.new(chunk_size * width, qtype)
  for i = 1, num_chunks do 
    local Dptr = ffi.cast("int32_t *", get_ptr(D, qtype))
    local offset = (i-1) * chunk_size
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
  local num_elements = tonumber(M[0].num_elements)
  -- print("num_elements = ", M[0].num_elements)
  -- print("num_chunks = ",   M[0].num_chunks)
  assert(M[0].num_chunks == num_chunks)
  
  for i = 1, num_chunks do 
    local s = v:get_chunk(i-1)
    assert(type(s) == "CMEM")
    assert(s:size() == chunk_size * width)
  end
  for i = 1, num_elements do 
    local s = v:get1(i-1)
    assert(s:to_num() == i)
  end
  print("Successfully completed test t2")
end
-- testing put1 and get1 for B1
tests.t3 = function()
  local qtype = "B1"
  local width = qconsts.qtypes[qtype].width
  local v = lVector.new(qtype, width);
  
  for i = 1, 1000000 do 
    local bval
    if ( ( i % 2 ) == 0 ) then bval = 1 else bval = 0 end 
    local s = Scalar.new(bval, "B1")
    v:put1(s)
    local M = assert(v:me())
    M = ffi.cast("VEC_REC_TYPE *", M)
    assert(M[0].num_elements == i, "failed at " .. i)
  end
  for i = 1, 1000000 do 
    local bval
    if ( ( i % 2 ) == 0 ) then bval = 1 else bval = 0 end 
    local s = v:get1(i-1)
    assert(type(s) == "Scalar")
    assert(s:fldtype() == "B1")
    assert(s:to_num() == bval, "Entry " .. i .. " expected " .. bval .. " got " .. s:to_num())
  end
  print("Successfully completed test t3")
end
-- not put after eov
-- no flush to disk before eov
tests.t4 = function()
  local qtype = "F4"
  local width = qconsts.qtypes[qtype].width
  local v = lVector.new(qtype, width);
  local n = 1000000
  for i = 1, n do 
    local s = Scalar.new(i, "F4")
    v:put1(s)
  end
  print(">>> start deliberate error")
  local status = v:flush_to_disk()
  print(status)
  print(">>>  stop deliberate error")
  v:eov()
  local status =  v:flush_to_disk(false); -- each chunk individually
  local status =  v:flush_to_disk(true); -- all data as one file 
  assert(status)
  assert(plpath.isfile(v:file_name()))
  local s = Scalar.new(0, "F4")
  print(">>> start deliberate error")
  local status = v:put1(s)
  assert(not status)
  print(">>>  stop deliberate error")
  local num_chunks = n / qconsts.chunk_size ;
  if ( ( num_chunks % n ) ~= 0 ) then num_chunks = num_chunks + 1 end 
  for i = 1, num_chunks do 
    local status = v:flush_to_disk(false, i-1)
    assert(status, i)
    local filesz = plpath.getsize(v:file_name(i-1))
    assert(filesz == qconsts.chunk_size * width)
  end
  print(">>> start deliberate error")
  local status = v:flush_to_disk(false, num_chunks)
  assert(not status)
  print(">>>  stop deliberate error")
  -- Now delete all the buffers
  for i = 1, num_chunks do 
    local status = v:flush_mem(i-1)
    assert(status)
  end

  -- Now get all the stuff you put in 
  for i = 1, n do 
    local sin = Scalar.new(i, "F4")
    local sout = v:get1(i-1)
    assert(sin == sout)
  end
  print("Successfully completed test t4")
end
-- test for reincarnate 
tests.t5 = function()
  local qtype = "F4"
  local width = qconsts.qtypes[qtype].width
  local v = lVector.new(qtype, width);
  local n = 1000000
  for i = 1, n do 
    local s = Scalar.new(i, "F4")
    v:put1(s)
  end
  assert(v:eov())
  assert(v:persist())
  assert(v:flush_to_disk(true))
  local M, C = assert(v:me())
  M = ffi.cast("VEC_REC_TYPE *", M)
  local S = {}
  S[#S+1] = "lVector("
  S[#S+1] = "{ "
  S[#S+1] = "has_nulls = false, "
  S[#S+1] = "qtype = \"" .. qtype .. "\"," 
  local sn = string.gsub(tostring(M[0].num_elements), "ULL", "")
  S[#S+1] = "num_elements = " .. sn .. ","

  local file_name = ffi.string(ffi.cast("char *", M[0].file_name))
  assert(plpath.isfile(file_name), "file not found " .. file_name)
  S[#S+1] = "file_name = " .. file_name .. ","

  S[#S+1] = "}"
  S[#S+1] = ") "
  local s = table.concat(S, " ")
  print(s)
  for i = 1, #C do
    local chunk = ffi.cast("CHUNK_REC_TYPE *", C[i])
  end
  status = v:__gc()
  assert(status)
  assert(plpath.isfile(file_name))
  print(">>> start deliberate error")
  status = v:delete()
  print("<<<< stop deliberate error")
  assert(not status)
  print("Successfully completed test t5")
  print("garbage collection starts")
end
-- return tests
tests.t1()
tests.t2()
os.exit()
tests.t3()
tests.t4()
tests.t5()
