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
local chunk_size = 65536
local params = { chunk_size = chunk_size, sz_chunk_dir = 4096, 
    data_dir = qconsts.Q_DATA_DIR }
assert(cVector.init_globals(params))
--=================================
local tests = {}
-- testing put1 and get1 
tests.t1 = function()
  local qtype = "F4"
  local width = qconsts.qtypes[qtype].width
  local v = cVector.new( { qtype = qtype, width = width} )
  print(">>> start deliberate error")
  assert( not  v:get1(0))
  assert( not  v:get1(-1))
  assert( not  v:get1(1))
  print(">>>  stop deliberate error")
  local M = assert(v:me())
  M = ffi.cast("VEC_REC_TYPE *", M)
  assert(M[0].num_elements == 0)
  assert(v:is_memo() == true)
  assert(v:memo(false))
  assert(v:memo(true))
  assert(v:is_memo() == true)
  print(M[0].chunk_size_in_bytes,  chunk_size, width)
  assert(M[0].chunk_size_in_bytes == (chunk_size * width))
  --=============

  local n = 1000000
  local exp_num_chunks = 0
  local exp_num_elements = 0
  -- put elements as 1, 2, 3, ...
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
    if ( ( i % 1000 ) == 0 ) then 
      assert(v.check_chunks())
    end
  end
  --================
  -- make sure you get what you put
  for i = 1, n do 
    local s = v:get1(i-1)
    assert(type(s) == "Scalar")
    assert(s:fldtype() == "F4")
    assert(s:to_num() == i, i)
  end
  --================
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
    -- note that get increments num_readers but get1 does not
    assert(chunk[0].num_readers == 0) 
    assert(chunk[0].num_writers == 0)
  end
  --====================
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
-- testing put1 and get1 for B1
tests.t3 = function()
  local qtype = "B1"
  local width = qconsts.qtypes[qtype].width
  local v = cVector.new({qtype = qtype, width = width})
  
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
  local v = cVector.new({qtype = qtype, width = width})
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
  local status =  v:flush_all(); 
  assert(status)
  assert(plpath.isfile(v:file_name()))
  local s = Scalar.new(0, "F4")
  print(">>> start deliberate error")
  local status = v:put1(s)
  assert(not status)
  print(">>>  stop deliberate error")
  local num_chunks = math.ceil(n / chunk_size) ;
  -- now we backup each chunk to file and delete in memory data
  for i = 1, num_chunks do 
    local free_mem = true
    local status = v:flush_chunk(i-1, free_mem)
    assert(status, i)
    local file_name = assert(v:file_name(i-1) )
    local filesz = assert(plpath.getsize(file_name))
    assert((filesz == chunk_size * width), "filesz = " ..filesz)
    assert(v:check())
    assert(v.check_chunks())
  end
  -- Now get all the stuff you put in 
  for i = 1, n do 
    local sin = Scalar.new(i, "F4")
    local sout = v:get1(i-1)
    assert(sin == sout)
  end
  assert(v:check())
  assert(v.check_chunks())
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
  local v = cVector.new({qtype = qtype, width = width})
  local n = 1000000
  for i = 1, n do 
    local s = Scalar.new(i, "F4")
    v:put1(s)
  end
  assert(v:eov())
  assert(v:persist())
  assert(v:flush_all())
  local M, C = assert(v:me())
  M = ffi.cast("VEC_REC_TYPE *", M)
  local S = {}
  S[#S+1] = "cVector("
  S[#S+1] = "{ "
  S[#S+1] = "has_nulls = false, "
  local qtype = ffi.string(M[0].fldtype)
  S[#S+1] = "qtype = \"" .. qtype .. "\"," 
  -- local sn = string.gsub(tostring(M[0].num_elements), "ULL", "")
  local sn = tonumber(M[0].num_elements)
  S[#S+1] = "num_elements = " .. sn .. ","

  S[#S+1] = "}"
  S[#S+1] = ") "
  local s = table.concat(S, " ")
  print(s)
  for i = 1, #C do
    local chunk = ffi.cast("CHUNK_REC_TYPE *", C[i])
  end
  status = v:__gc()
  assert(status)
  print(">>> start deliberate error")
  status = v:delete()
  print("<<<< stop deliberate error")
  print("Successfully completed test t5")
  print("garbage collection starts")
end
-- testing flushing files 
tests.t6 = function()
  local qtype = "F4"
  local width = qconsts.qtypes[qtype].width
  local v = cVector.new({qtype = qtype, width = width})
  local M = v:me()
  M = ffi.cast("VEC_REC_TYPE *", M)
  local n = M[0].chunk_size_in_bytes* 4
  --=============
  for i = 1, n do 
    local s = Scalar.new(i, "F4") v:put1(s)
  end
  --=============
  -- cannot flush until eov 
  print(">>> start deliberate error")
  local x, status = pcall(v.flush_all, v)
  assert(not status) 
  print(">>>  stop deliberate error")
  -- master file not created until requested
  v:eov()
  assert(not plpath.isfile(v:file_name()))
  -- create master file, then delete it and verify its gone
  assert(v:flush_all())
  local M = v:me()
  M = ffi.cast("VEC_REC_TYPE *", M)
  assert(M[0].is_file == true)
  assert(plpath.isfile(v:file_name()))
  --==================
  assert(v:delete_master_file())
  assert(not plpath.isfile(v:file_name()))
  -- check isfile == false
  local M = v:me()
  M = ffi.cast("VEC_REC_TYPE *", M)
  assert(M[0].is_file == false)
  --============ Now check that chunks do not have files 
  local V, C = assert(v:me())
  for i = 1, #C do
    local chunk = ffi.cast("CHUNK_REC_TYPE *", C[i])
    assert(not chunk[0].is_file)
  end
  --=============================
  --= flush all chunks and then verify that they have files 
  for i = 1, #C do
    v:flush_chunk(i-1)
  end
  local V, C = assert(v:me())
  for i = 1, #C do
    local chunk = ffi.cast("CHUNK_REC_TYPE *", C[i])
    assert(chunk[0].is_file)
  end
  --=============================
  --= delete chunk files and then verify that are gone
  for i = 1, #C do
    v:delete_chunk_file(i-1)
  end
  local V, C = assert(v:me())
  for i = 1, #C do
    local chunk = ffi.cast("CHUNK_REC_TYPE *", C[i])
    assert(not chunk[0].is_file)
  end
  assert(v:check())
  assert(v.check_chunks())
  --=============================
  print("Successfully completed test t6")
end
-- testing number of chunks == 1 when is_memo = false
tests.t7 = function()
  local qtype = "I4"
  local width = qconsts.qtypes[qtype].width
  local v = cVector.new({qtype = qtype, width = width})
  v:memo(false) -- set memo to true
  assert(v:is_memo() == false)
  --=============
  local M = assert(v:me())
  M = ffi.cast("VEC_REC_TYPE *", M)
  assert(
    math.ceil(M[0].chunk_size_in_bytes / width) == 
    math.floor(M[0].chunk_size_in_bytes / width))
  --=============
  local num_chunks = 1024
  local D = cmem.new(chunk_size * width, qtype)
  for i = 1, num_chunks do 
    -- assemble some known data 
    local Dptr = ffi.cast("int32_t *", get_ptr(D, qtype))
    local offset = (i-1) * chunk_size
    for i = 1, chunk_size do
      Dptr[i-1] = offset + i
    end
    -- put a chunk of known data 
    v:put_chunk(D)
    local M = assert(v:me())
    M = ffi.cast("VEC_REC_TYPE *", M)
    assert(M[0].num_chunks == 1)
    assert(M[0].num_elements == i*chunk_size, "failed at " .. i)
    assert(v:check())
    assert(v.check_chunks())
    
    local chk_D, nD = v:get_chunk(i-1)
    local chk_Dptr = ffi.cast("int32_t *", get_ptr(chk_D, qtype))
    assert(nD == chunk_size)
    for i = 1, chunk_size do
      assert(chk_Dptr[i-1] == Dptr[i-1])
    end
    v:unget_chunk(i-1)
  end
  print("Successfully completed test t7")
end
-- testing reincarnate
tests.t8 = function()
  for iter = 1, 2 do 
    local qtype = "I4"
    local width = qconsts.qtypes[qtype].width
    local v = cVector.new({qtype = qtype, width = width})
    v:persist()
    assert(v:is_memo() == true)
    --=============
    local M = assert(v:me())
    M = ffi.cast("VEC_REC_TYPE *", M)
    assert(M[0].is_persist == true)
    local chunk_size = math.ceil(M[0].chunk_size_in_bytes / 
      qconsts.qtypes[qtype].width)
    assert(chunk_size == math.floor(M[0].chunk_size_in_bytes / 
      qconsts.qtypes[qtype].width))
    --=============
    local num_chunks = 1024
    local D = cmem.new(chunk_size * width, qtype)
    for i = 1, num_chunks do 
      -- assemble some known data 
      local Dptr = ffi.cast("int32_t *", get_ptr(D, qtype))
      local offset = (i-1) * chunk_size
      for i = 1, chunk_size do Dptr[i-1] = offset + i end
      -- put a chunk of known data 
      v:put_chunk(D)
      local M = assert(v:me())
      M = ffi.cast("VEC_REC_TYPE *", M)
      assert(M[0].num_chunks == i, i)
      end
    v:eov()
    if ( iter == 2 ) then 
      v:flush_all()
    end
    local x = v:shutdown() 
    assert(type(x) == "string") 
    assert(#x > 0)
    y = loadstring(x)()
    assert(y.num_elements == num_chunks * chunk_size)
    assert(y.field_width == qconsts.qtypes[qtype].width)
    assert(y.fldtype == qtype)
    if ( iter == 1 ) then 
      assert(not y.file_name)
      assert(type(y.file_names) == "table")
      assert(#y.file_names == num_chunks)
      for k, v in pairs(y.file_names) do 
        assert(plpath.isfile(v)) 
      end
    end
    if ( iter == 2 ) then 
      assert(not y.file_names)
      assert(type(y.file_name) == "string")
      assert(plpath.isfile(y.file_name)) 
    end 
    -- clean up after yourself
    local ddir = qconsts.Q_DATA_DIR
    pldir = require 'pl.dir'
    pldir.rmtree(ddir)
    pldir.makepath(ddir)
    --=====================
  end
  print("Successfully completed test t8")
end
-- testing reincarnate when memo is false
tests.t9 = function()
  for case = 1, 2 do 
    -- case = 1 => num_elements <= chunk_size, memo = false
    -- case = 2 => num_elements >  chunk_size, memo = false
    local qtype = "I4"
    local width = qconsts.qtypes[qtype].width
    local v = cVector.new({qtype = qtype, width = width})
    local num_elements
    v:memo(false)
    v:persist(true)
    if ( case == 1 ) then 
      num_elements = chunk_size
    elseif ( case == 2 ) then 
      num_elements = chunk_size + 1
    else 
      error("bad case")
    end 
    --=============
    for i = 1, num_elements do 
      local s = Scalar.new(i,qtype)
      assert(v:put1(s))
    end
    v:eov()
    --==================
    local x = v:shutdown() 
    if ( case == 1 ) then 
      assert(type(x) == "string") 
      assert(#x > 0)
      y = loadstring(x)()
      assert(y.num_elements == num_elements)
      assert(y.field_width == width)
      assert(y.fldtype == qtype)
    elseif ( case == 2 ) then 
      assert(x == nil)
    else
      error("bad case")
    end
  end
  -- clean up after yourself
  local ddir = qconsts.Q_DATA_DIR
  pldir = require 'pl.dir'
  pldir.rmtree(ddir)
  pldir.makepath(ddir)
  --=====================
  print("Successfully completed test t9")
end
-- return tests

tests.t1() -- PASSES
tests.t3() -- PASSES
tests.t4() -- PASSES 
tests.t5() -- PASSES
tests.t6() -- PASSES
tests.t7() -- PASSES
tests.t8() -- PASSES
tests.t9() -- PASSES
os.exit()
