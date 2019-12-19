local cutils = require 'libcutils'
local plpath = require 'pl.path'
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local get_func_decl = require 'Q/UTILS/build/get_func_decl'

local hdrs = get_func_decl("../inc/core_vec_struct.h", " -I../../../UTILS/inc/")
ffi.cdef(hdrs)
-- following only because we are testing. Normally, we get this from q_core
local hdrs = get_func_decl("../../CMEM/inc/cmem_struct.h", " -I../../../UTILS/inc/")
ffi.cdef(hdrs)
--=================================
local tests = {}
-- testing put1 and get1 
tests.t1 = function()
  local qtype = "F4"
  local width = qconsts.qtypes[qtype].width
  local v = cVector.new(qtype, width);
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
  
  --=============
  local chunk_size = 65536 
  -- above is brittle but here is a test to verify it is in sync
  -- with g_chunk_size
  assert(M[0].chunk_size_in_bytes ==
    (chunk_size * qconsts.qtypes[qtype].width))
  --=============

  local n = 1000000
  local exp_num_chunks = 0
  local exp_num_elements = 0
  for i = 1, n do 
    local s = Scalar.new(i, "F4")
    v:put1(s)
    if ( i == 1 ) then 
      print(">>> start deliberate error")
      print( v:memo(true)) 
      assert( not v:memo(true)) 
      print(">>>  stop deliberate error")
    end
    exp_num_elements = exp_num_elements + 1
    local M = assert(v:me())
    M = ffi.cast("VEC_REC_TYPE *", M)
    assert(M[0].num_elements == exp_num_elements)
    exp_num_chunks = math.ceil(exp_num_elements / chunk_size)
    assert(M[0].num_chunks == exp_num_chunks)
    assert(v:check())
  end
  for i = 1, n do 
    local s = v:get1(i-1)
    assert(type(s) == "Scalar")
    assert(s:fldtype() == "F4")
    assert(s:to_num() == i)
  end
  local V, C = assert(v:me())
  V = ffi.cast("VEC_REC_TYPE *", M)
  assert(type(C) == "table")
  local chunk_nums = {}
  local uqids = {}
  for i = 1, #C do
    local chunk = ffi.cast("CHUNK_REC_TYPE *", C[i])
    assert(chunk[0].vec_uqid == V[0].uqid)
    chunk_nums[#chunk_nums+1] = chunk[0].chunk_num
    uqids[#uqids+1] = chunk[0].uqid
    -- assert(chunk[0].num_readers == 0) TODO Think about thsi one
    assert(chunk[0].num_writers == 0)
  end
  for k1, v1 in pairs(chunk_nums) do 
    for k2, v2 in pairs(chunk_nums) do 
      if ( k1 ~= k2 ) then assert(v1 ~= v2) end
    end
    assert( ( v1 >= 0 ) and ( v1 < V[0].num_chunks) )
  end
  for k1, v1 in pairs(uqids) do 
    for k2, v2 in pairs(uqids) do 
      if ( k1 ~= k2 ) then assert(v1 ~= v2) end
    end
  end
  --===============================
  -- cVector:print_timers()
  cVector:reset_timers()
  print("Successfully completed test t1")
end
-- testing put_chunk and get_chunk
tests.t2 = function()
  local qtype = "I4"
  local width = qconsts.qtypes[qtype].width
  local v = cVector.new(qtype, width);
  
  --=============
  local M = assert(v:me())
  M = ffi.cast("VEC_REC_TYPE *", M)
  local chunk_size = 65536 
  -- above is brittle but here is a test to verify it is in sync
  -- with g_chunk_size
  assert(M[0].chunk_size_in_bytes ==
    (chunk_size * qconsts.qtypes[qtype].width))
  --=============
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
    assert(M[0].num_chunks == i)
    assert(M[0].num_elements == i*chunk_size, "failed at " .. i)
    assert(v:check())
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
  local v = cVector.new(qtype, width);
  
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
  -- check no files in data directory
  local ddir = os.getenv("Q_DATA_DIR")
  local pldir = require 'pl.dir'
  pldir.rmtree(ddir)
  pldir.makepath(ddir)
  local x = pldir.getfiles(ddir, "_*.bin")
  assert( x == nil or #x == 0 )
  local qtype = "F4"
  local width = qconsts.qtypes[qtype].width
  local v = cVector.new(qtype, width);
  v:persist(false)
  local n = 1000000
  for i = 1, n do 
    local s = Scalar.new(i, "F4")
    v:put1(s)
  end
  print(">>> start deliberate error")
  local status = v:flush_all()
  print(status)
  print(">>>  stop deliberate error")
  v:eov()
  local status =  v:flush_all(); -- each chunk individually
  assert(status)
  assert(plpath.isfile(v:file_name()))
  local s = Scalar.new(0, "F4")
  print(">>> start deliberate error")
  local status = v:put1(s)
  assert(not status)
  print(">>>  stop deliberate error")
  local num_chunks = math.ceil(n / qconsts.chunk_size) ;
  for i = 1, num_chunks do 
    local status = v:flush_chunk(i-1)
    assert(status, i)
    local filesz = plpath.getsize(v:file_name(i-1))
    assert(filesz == qconsts.chunk_size * width)
  end
  -- Now delete all the buffers
  -- TODO need to implement delete data, delete file 

  -- Now get all the stuff you put in 
  for i = 1, n do 
    local sin = Scalar.new(i, "F4")
    local sout = v:get1(i-1)
    assert(sin == sout)
  end
  local x = pldir.getfiles(ddir, "_*.bin")
  print(#x, num_chunks)
  assert(#x == num_chunks + 1 ) -- +1 for whole file
  local r = cutils.rdtsc() % 3
  print("random choice = ", r)
  if ( r == 0 ) then v:delete() end 
  if ( r == 1 ) then v = nil collectgarbage() end 
  if ( ( r == 0 ) or ( r == 1 ) ) then 
    local x = pldir.getfiles(ddir, "_*.bin")
    for k, v in pairs(x) do print(k, v) end 
    assert(x == nil or #x == 0 )
  end
  print("Successfully completed test t4")
end
-- test for reincarnate 
tests.t5 = function()
  local qtype = "F4"
  local width = qconsts.qtypes[qtype].width
  local v = cVector.new(qtype, width);
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
  S[#S+1] = "cVector("
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
-- tests.t1()
-- tests.t2()
-- tests.t3()
tests.t4()
os.exit()
tests.t5()
