require 'Q/UTILS/lua/strict'
local cutils = require 'libcutils'
local plpath = require 'pl.path'
local ffi     = require 'ffi'
local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
local cmem    = require 'libcmem'
local qconsts = require 'Q/UTILS/lua/qconsts'
local qmem    = require 'Q/UTILS/lua/qmem'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local pldir   = require 'pl.dir'

local function delete_data_files()
  local ddir = os.getenv("Q_DATA_DIR")
  pldir.rmtree(ddir)
  pldir.makepath(ddir)
end
local function get_data_files()
  local ddir = os.getenv("Q_DATA_DIR")
  return pldir.getfiles(ddir, "_*.bin")
end

local tests = {}

local lVector 
local modes
local test_without_q = false
if test_without_q then 
  -- following only because we are testing. 
  -- Normally, we get this from q_ore
  local get_func_decl = require 'Q/UTILS/build/get_func_decl'
  local hdrs = get_func_decl("../inc/vctr_struct.h", " -I../../../UTILS/inc/")
  ffi.cdef(hdrs)
  modes = { "cVector" }
else
  lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
  modes = { "cVector", "lVector" }
end
--=================================
-- testing put1 and get1 
tests.t1 = function()
  local qtype = "F4"
  local width = qconsts.qtypes[qtype].width
  local v 
  for _, mode in pairs(modes) do 
    if ( mode == "cVector" ) then 
      v = cVector.new( { qtype = qtype, width = width} )
    elseif ( mode == "lVector" ) then 
      v = lVector.new( { qtype = qtype, width = width} )
    else
      error("")
    end
    print(">>> start deliberate error")
    if ( mode == "cVector" ) then 
      assert( not  v:get1(0))
      assert( not  v:get1(-1))
      assert( not  v:get1(1))
    elseif ( mode == "lVector" ) then 
      local status = pcall(v.get1, 0)  assert( not  status) 
      status = pcall(v.get1,-1)  assert( not  status) 
      status = pcall(v.get1,1)   assert( not  status) 
    else
      error("")
    end
    print(">>>  stop deliberate error")
    local M = assert(v:me())
    M = ffi.cast("VEC_REC_TYPE *", M)
    assert(M[0].num_elements == 0)
    assert(ffi.cast("VEC_REC_TYPE *", v:me())[0].is_memo == true)
    assert(v:memo(false))
    assert(ffi.cast("VEC_REC_TYPE *", v:me())[0].is_memo == false)
    assert(v:memo(true))
    assert(ffi.cast("VEC_REC_TYPE *", v:me())[0].is_memo == true)
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
        if ( mode == "cVector" ) then 
          assert( not v:memo(true)) 
        elseif ( mode == "lVector" ) then 
          local status = pcall(v.memo, true)
          assert( not status)
        else
          error("")
        end
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
        assert(cVector.check_chunks())
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
  end
  --===============================
  -- cVector:print_timers()
  cVector:reset_timers()
  print("Successfully completed test t1")
end
-- testing start_read/end_read, start_write, end_write
-- testing writing the vector after open wih start_write
-- a few simple tests for master()
-- a few simple tests for unmaster and delete_chunk_file
tests.t2 = function()
  local status
  local qtype = "I8"
  local width = qconsts.qtypes[qtype].width
  local v = lVector.new( { qtype = qtype, width = width} )
  
  local n = 2 * chunk_size + 17 
  local num_chunks = math.ceil(n / chunk_size)
  for i = 1, n do 
    local s = Scalar.new(i, qtype)
    v:put1(s)
  end
--  print(">>> start deliberate error")
  status = pcall(v.start_read) assert(not status)
  status = pcall(v.start_write) assert(not status)
  status = pcall(v.end_read) assert(not status)
  status = pcall(v.end_write) assert(not status)
--  print("<<< stop  deliberate error")
  v:eov()
  local X = {}
  local Y = {} 
  local Z = {}
  for i = 1, 10 do 
    local x, y, z = v:start_read()
    X[#X+1] = x
    Y[#Y+1] = y
    Z[#Z+1] = x
  end
  status = pcall(v.start_write) assert(not status)
  status = pcall(v.end_write) assert(not status)
  for i = 1, 10 do 
    assert(v:end_read())
  end
  status = pcall(v.end_read) assert(not status)
  local m, cmem, nn_cmem = v:start_write()
  assert(type(cmem) == "CMEM")
  assert(m == n)
  -- first call to end_write should succeed
  assert(v:end_write())
  -- second call to end_write should fail
  status = pcall(v.end_write) assert(not status)
  -- testing writing the vector after open wih start_write
  -- open vector for writing and write some new values
  local m, cmem, nn_cmem = v:start_write()
  local lptr = get_ptr(cmem, "I8")
  for i = 1, n do 
    lptr[i-1] = 2*i 
  end
  assert(v:end_write())
  -- open vector for reading and test new values took effect
  local m, cmem, nn_cmem = v:start_read()
  local lptr = ffi.cast("int64_t *", get_ptr(cmem, qtype))
  for i = 1, n do 
    assert(lptr[i-1] == 2*i)
  end
  assert(v:end_read())
  -- Checking flush_all and delete_master_file and delete_chunk_file
  local width = qconsts.qtypes[qtype].width
  for iter = 1, 20 do 
    local exp_file_size = num_chunks * chunk_size * width
    v:master() -- create master file, multiple calls not a problem
    local f1, _ = v:file_name()
    assert(plpath.isfile(f1))
    assert(plpath.getsize(f1) == exp_file_size)
    v:unmaster() -- deletes master file, multiple calls not a problem
    assert(not plpath.isfile(f1))
  end
  for iter = 1, 20 do 
    local exp_file_size = chunk_size * width
    local full_fsz = 0
    for chunk_num = 1, num_chunks do
      v:make_chunk_file(chunk_num-1) -- create chunk file 
      local f1, _ = v:file_name(chunk_num-1)
      assert(plpath.isfile(f1))
      assert(plpath.getsize(f1) == exp_file_size)
      v:delete_chunk_file(chunk_num-1)
      -- Check that they no longer exist
      for i = 1, num_chunks do
        local f1, f2 = v:file_name(i-1)
        assert(not plpath.isfile(f1))
      end
    end
  end

  print("Successfully completed test t2")
end
  --===========================
-- testing put1 and get1 for B1
tests.t3 = function()
  for _, mode in pairs(modes) do 
    local qtype = "B1"
    local width = qconsts.qtypes[qtype].width
    local v
    if ( mode == "cVector" ) then 
      v = cVector.new({qtype = qtype, width = width})
    elseif ( mode == "lVector" ) then 
      if ( test_without_q ) then 
        print("Not testing lVector")
        break
      end
      print("Testing lVector")
      v = lVector.new({qtype = qtype, width = width})
    else
      error("base case")
    end
    local n = 1000000
    for i = 1, n do 
      local bval
      if ( ( i % 2 ) == 0 ) then bval = 1 else bval = 0 end 
      local s = Scalar.new(bval, "B1")
      v:put1(s)
      local M = assert(v:me())
      M = ffi.cast("VEC_REC_TYPE *", M)
      assert(M[0].num_elements == i, "failed at " .. i)
    end
    for i = 1, n do 
      local bval
      if ( ( i % 2 ) == 0 ) then bval = 1 else bval = 0 end 
      local s = v:get1(i-1)
      assert(type(s) == "Scalar")
      assert(s:fldtype() == "B1")
      assert(s:to_num() == bval, "Entry " .. i .. " expected " .. bval .. " got " .. s:to_num())
    end
    -- ask for one more than exists. Should error
    print(">>> start deliberate error")
    if ( mode == "cVector" ) then 
      local x, y, z = v:get1(n)
      assert(not x) assert(y == "l_vec_get1")
      --== ask for less than 0 
      local x, y, z = v:get1(-1)
      assert(not x) assert(y == "l_vec_get1")
    elseif ( mode == "lVector" ) then 
      local x, y, z = pcall(v.get1, v, n)
      assert(not x) 
      --== ask for less than 0 
      local x, y, z = pcall(v.get1, v, -1)
      assert(not x) 
    end
    print("<<<  stop deliberate error")
  end
  print("Successfully completed test t3")
end
-- not put after eov
-- no flush to disk before eov
tests.t4 = function()
  local modes = { "cVector", "lVector" }
  for _, mode in pairs(modes) do 
    delete_data_files()
    local x = get_data_files()
    assert( x == nil or #x == 0 )
    local qtype = "F4"
    local width = qconsts.qtypes[qtype].width
    local v
    if ( mode == "cVector" ) then 
      print("Testing cVector")
      v = cVector.new({qtype = qtype, width = width})
    elseif ( mode == "lVector" ) then 
      if ( test_without_q ) then 
        print("Not testing lVector")
        break
      end
      print("Testing lVector")
      v = lVector.new({qtype = qtype, width = width})
    else
      error("base case")
    end
    v:persist(false)
    local n = 1000000
    for i = 1, n do 
      local s = Scalar.new(i, "F4")
      v:put1(s)
    end
    print(">>> start deliberate error")
    if ( mode == "cVector" ) then 
      local status = v:master()
      assert(not status)
    elseif ( mode == "lVector" ) then 
      local status = pcall(v.master)
      assert(not status)
    else
      error("")
    end
    print(">>>  stop deliberate error")
    assert(v:eov())
    assert(v:master())
    assert(plpath.isfile(v:file_name()))
    local s = Scalar.new(0, "F4")
    print(">>> start deliberate error")
    if ( mode == "cVector" ) then 
      local status = v:put1(s)
      assert(not status)
    elseif ( mode == "lVector" ) then 
      local status = pcall(v.put1, s)
      assert(not status)
    else
      error("")
    end
    print(">>>  stop deliberate error")
    local num_chunks = math.ceil(n / chunk_size) ;
    -- now we backup each chunk to file and delete in memory data
    for chunk_num = 1, num_chunks do 
      local free_mem = true
      assert(v:make_chunk_file(chunk_num-1, free_mem))
      local file_name = assert(v:file_name(chunk_num-1) )
      local filesz = assert(plpath.getsize(file_name))
      assert(filesz == chunk_size * width)
      assert(v:check())
      assert(cVector.check_chunks())
    end
    -- Now get all the stuff you put in 
    for i = 1, n do 
      local sin = Scalar.new(i, "F4")
      local sout = v:get1(i-1)
      assert(sin == sout)
    end
    assert(v:check())
    assert(cVector.check_chunks())
    local x = get_data_files()
    print(#x, num_chunks)
    assert(#x == num_chunks + 1 ) -- +1 for whole file
    local r = cutils.rdtsc() % 3
    print("random choice = ", r)
    if ( r == 0 ) then 
      v:delete() 
    elseif ( r == 1 ) then 
      v = nil collectgarbage() 
    else
      -- do nothing
    end 
    if ( ( r == 0 ) or ( r == 1 ) ) then 
      local x = get_data_files()
      for k, v in pairs(x) do print(k, v) end 
      assert(x == nil or #x == 0 )
    end
  end
  print("Successfully completed test t4")
end
-- test for reincarnate 
tests.t5 = function()
  local qtype = "F4"
  local width = qconsts.qtypes[qtype].width
  local v 
  for _, mode in pairs(modes) do 
    if ( mode == "cVector" ) then 
      v = cVector.new( { qtype = qtype, width = width} )
    elseif ( mode == "lVector" ) then 
      v = lVector.new( { qtype = qtype, width = width} )
    else
      error("")
    end
    local n = 2 * cVector.chunk_size() + 17 
    for i = 1, n do 
      local s = Scalar.new(i, "F4")
      v:put1(s)
    end
    assert(v:eov())
    assert(v:persist())
    assert(v:master())
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
    local status
    if ( mode == "cVector" ) then 
      status = v:__gc()
    elseif ( mode == "lVector" ) then 
      status = v:free()
    else
      errr("")
    end
    assert(status)
    print(">>> start deliberate error")
    status = v:delete()
    print("<<<< stop deliberate error")
    print("Successfully completed test t5 for mode = " .. mode)
    print("garbage collection starts")
  end
end
-- testing flushing files 
tests.t6 = function()
  local qtype = "F4"
  local width = qconsts.qtypes[qtype].width
  local v 
  for _, mode in pairs(modes) do 
    delete_data_files()
    if ( mode == "cVector" ) then 
      v = cVector.new( { qtype = qtype, width = width} )
    elseif ( mode == "lVector" ) then 
      v = lVector.new( { qtype = qtype, width = width} )
    else
      error("")
    end
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
    if ( mode == "cVector" ) then 
      local status = v:master()
      assert(not status) 
    elseif ( mode == "lVector" ) then 
      local status = pcall(v.master, v)
      assert(not status) 
    else
      err("")
    end
    print(">>>  stop deliberate error")
    -- now terminate the vector 
    v:eov() 
    -- master file not created until requested
    assert(not plpath.isfile(v:file_name()))
    --============ check that chunks do not have files 
    local V, C = assert(v:me())
    for i = 1, #C do
      local chunk = ffi.cast("CHUNK_REC_TYPE *", C[i])
      assert(not chunk[0].is_file)
    end
    --=============================
    -- create master file, check it exists, 
    -- then delete it and verify its gone
    assert(v:master())
    local M = v:me()
    M = ffi.cast("VEC_REC_TYPE *", M)
    assert(M[0].is_file == true)
    assert(plpath.isfile(v:file_name()))
    --==================
    assert(v:unmaster())
    assert(not plpath.isfile(v:file_name()))
    -- check isfile == false
    local M = v:me()
    M = ffi.cast("VEC_REC_TYPE *", M)
    assert(M[0].is_file == false)
    --= flush all chunks and then verify that they have files 
    for i = 1, #C do
      v:make_chunk_file(i-1)
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
    assert(cVector.check_chunks())
    --=============================
  end
  print("Successfully completed test t6")
end
-- testing number of chunks == 1 when is_memo = false
tests.t7 = function()
  local qtype = "I4"
  local width = qconsts.qtypes[qtype].width
  for _, mode in pairs(modes) do 
    local v 
    if ( mode == "cVector" ) then 
      v = cVector.new( { qtype = qtype, width = width} )
    elseif ( mode == "lVector" ) then 
      v = lVector.new( { qtype = qtype, width = width} )
    else
      error("")
    end
    v:memo(false) -- set memo to false
    assert(ffi.cast("VEC_REC_TYPE *", v:me())[0].is_memo == false)
    --=============
    local M = assert(v:me())
    M = ffi.cast("VEC_REC_TYPE *", M)
    assert(
      math.ceil(M[0].chunk_size_in_bytes / width) == 
      math.floor(M[0].chunk_size_in_bytes / width))
    --=============
    local num_chunks = 1024
    local D = cmem.new({size = chunk_size * width, qtype=qtype})
    local exp_num_elements = 0
    for chunk_idx = 0, num_chunks-1 do 
      assert(not v:is_eov())
      -- assemble some known data  as 1, 2, 3, ....
      local Dptr = get_ptr(D, qtype)
      local offset = chunk_idx * chunk_size
      for i = 1, chunk_size do
        Dptr[i-1] = offset + i
      end
      -- put a chunk of known data 
      if ( mode == "cVector" ) then 
        cVector.put_chunk(v, D, chunk_size)
      elseif ( mode == "lVector" ) then 
        assert(v:put_chunk(D))
      else
        error("")
      end
      local M = assert(v:me())
      M = ffi.cast("VEC_REC_TYPE *", M)

      assert(M[0].num_chunks == 1) -- because of is_memo

      exp_num_elements = exp_num_elements + chunk_size
      assert(M[0].num_elements == exp_num_elements)

      assert(v:check())
      assert(cVector.check_chunks())
      
      local chk_D, nD
      if ( mode == "cVector" ) then
        chk_D, nD = v:get_chunk(chunk_idx)
      elseif ( mode == "lVector" ) then
        nD, chk_D = v:get_chunk(chunk_idx)
      else
        error("")
      end
      assert(type(chk_D) == "CMEM")
      assert(type(nD) == "number")
      local chk_Dptr = get_ptr(chk_D, qtype)
      assert(nD == chunk_size)
      for i = 1, chunk_size do
        assert(chk_Dptr[i-1] == Dptr[i-1])
      end
      v:unget_chunk(chunk_idx)
    end
  end
  print("Successfully completed test t7")
end
-- testing reincarnate
tests.t8 = function()
  for iter = 1, 2 do 
    local qtype = "I4"
    local width = qconsts.qtypes[qtype].width
    for _, mode in pairs(modes) do 
      local v 
      if ( mode == "cVector" ) then 
        v = cVector.new( { qtype = qtype, width = width} )
      elseif ( mode == "lVector" ) then 
        v = lVector.new( { qtype = qtype, width = width} )
      else
        error("")
      end
      v:persist()
      --=============
      local M = v:me()
      M = ffi.cast("VEC_REC_TYPE *", M)
      assert(M[0].is_memo == true)
      assert(M[0].is_persist == true)
      assert(chunk_size == math.floor(M[0].chunk_size_in_bytes / 
        qconsts.qtypes[qtype].width))
      --=============
      local num_chunks = 1024
      local D = cmem.new({size = chunk_size * width, qtype = qtype})
      for chunk_idx = 0, num_chunks-1 do 
        -- assemble some known data  as 0, 1, 2, 3, ...
        local Dptr = get_ptr(D, qtype)
        local offset = chunk_idx * chunk_size
        for didx = 0, chunk_size-1 do 
          Dptr[didx] = offset + didx
        end
        -- put a chunk of known data 
        if ( mode == "cVector" ) then 
          cVector.put_chunk(v, D, chunk_size)
        elseif ( mode == "lVector" ) then 
          v:put_chunk(D)
        else
          error("")
        end
        local M = assert(v:me())
        M = ffi.cast("VEC_REC_TYPE *", M)
        assert(M[0].num_chunks == chunk_idx+1)
      end
      v:eov()
      local x = v:shutdown() 
      assert(type(x) == "string") 
      assert(#x > 0)
      local y = loadstring(x)()
      assert(type(y) == "table")
      assert(y.num_elements == num_chunks * chunk_size)
  
      assert(y.width == qconsts.qtypes[qtype].width)
      assert(y.qtype == qtype)
      assert(type(y.vec_uqid) == "number")
      assert(type(y.chunk_uqids) == "table")
      assert(#y.chunk_uqids == num_chunks)
      for k, v in pairs(y.chunk_uqids) do 
        assert(type(v) == "number")
      end
      for k1, v1 in pairs(y.chunk_uqids) do 
        for k2, v2 in pairs(y.chunk_uqids) do 
          if ( k1 ~= k2 ) then assert(v1 ~= v2) end
        end
      end
      if ( mode == "lVector" ) then 
        -- Create a vector with the information in y
        local z = lVector(y)
        assert(type(z) == "lVector")
      end
      -- clean up after yourself
      local ddir = cVector.data_dir()
      local pldir = require 'pl.dir'
      pldir.rmtree(ddir)
      pldir.makepath(ddir)
      --=====================
    end
  end
  print("Successfully completed test t8")
end
-- testing reincarnate when memo is false
tests.t9 = function()
  for _, mode in pairs(modes) do 
    for case = 1, 2 do 
      -- case = 1 => num_elements <= chunk_size, memo = false
      -- case = 2 => num_elements >  chunk_size, memo = false
      local qtype = "I4"
      local width = qconsts.qtypes[qtype].width
      local v
      if ( mode == "cVector" ) then 
        v = cVector.new( { qtype = qtype, width = width} )
      elseif ( mode == "lVector" ) then 
        v = lVector.new( { qtype = qtype, width = width} )
      else
        error("")
      end
      v:memo(false)
      v:persist(true)
      local num_elements
      --=============
      if ( case == 1 ) then 
        num_elements = chunk_size
      elseif ( case == 2 ) then 
        num_elements = chunk_size + 1
      else 
        error("bad case")
      end 
      --=============
      print("Starting put ", mode, case)
      for i = 1, num_elements do 
        local s = Scalar.new(i,qtype)
        assert(v:put1(s), "mode = " .. mode)
      end
      v:eov()
      --==================
      if ( mode == "cVector" ) then 
        local x = v:shutdown() 
        if ( case == 1 ) then 
          assert(type(x) == "string") 
          assert(#x > 0)
          local y = loadstring(x)()
          assert(y.num_elements == num_elements)
          assert(y.width == width)
          assert(y.qtype == qtype)
        elseif ( case == 2 ) then 
          assert(x == nil)
        else
          error("bad case")
        end
      elseif ( mode == "lVector" ) then 
        if ( case == 1 ) then 
          local x = v:shutdown() 
          assert(type(x) == "string") 
          assert(#x > 0)
          local y = loadstring(x)()
          assert(y.num_elements == num_elements)
          assert(y.width == width)
          assert(y.qtype == qtype)
        elseif ( case == 2 ) then 
          local x v:shutdown()
          assert(not x)
        else
          error("bad case")
        end
      else
        error("")
      end
    end
    -- clean up after yourself
    local ddir = cVector.data_dir()
    local pldir = require 'pl.dir'
    pldir.rmtree(ddir)
    pldir.makepath(ddir)
  end
  --=====================
  print("Successfully completed test t9")
end
-- t10 tests drop_nulls, make_nulls
tests.t10 = function()
  local status
  -- make the base vector 
  local qtype = "F8"
  local v = lVector.new( { qtype = qtype} )
  local n = 2 * cVector.chunk_size() + 17 
  for i = 1, n do 
    local s = Scalar.new(i, qtype)
    v:put1(s)
  end
  for iter = 1, 3 do 
    -- make the nn vector 
    local qtype = "B1"
    local nn_v = lVector.new( { qtype = qtype} )
    local n = 2 * cVector.chunk_size() + 17 
    for i = 1, n do 
      local s 
      if ( ( i % 2 ) == 0 ) then 
        s = Scalar.new(true, qtype)
      else
        s = Scalar.new(false, qtype)
      end
      nn_v:put1(s)
    end
    assert(v:drop_nulls())
    v:eov()
    assert(v:drop_nulls())
    assert(v:make_nulls(nn_v))
    assert(v:has_nulls())
    assert(v:drop_nulls())
    assert(not v:has_nulls())
  end
  print("Successfully completed test t10")
end
  --===========================
tests.t1() -- PASSES
--[[
return tests
tests.t2() -- PASSES
tests.t3() -- PASSES
tests.t4() -- PASSES 
tests.t5() -- PASSES
tests.t6() -- PASSES
tests.t7() -- PASSES
tests.t8() -- PASSES
tests.t9() -- PASSES
tests.t10() -- PASSES
os.exit()
--]]
