local cutils = require 'libcutils'
local plutils= require 'pl.utils'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local ffi     = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local lgutils  = require 'liblgutils'
-- TODO P1 Set below to true 
local test_print  = true -- turn false if you want only load_csv tested
--=======================================================
local tests = {}
tests.t1 = function()
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local M = {}
  local O = { is_hdr = true }
  -- TODO P1 Test with different memo_len values 
  M[1] = { name = "i4", qtype = "I4", memo_len = -1 }
  M[2] = { name = "f4", qtype = "F4", memo_len = -1  }
  local datafile = qcfg.q_src_root .. "/OPERATORS/LOAD_CSV/test/in1.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  local num_cols = 0
  assert(type(T) == "table")
  for k, v in pairs(T) do 
    num_cols = num_cols + 1
    assert(type(v) == "lVector")
    if ( k == "i4" ) then 
      assert(v:qtype() == "I4") 
    elseif ( k == "f4" ) then 
      assert(v:qtype() == "F4") 
    else
      error("")
    end 
  end
  assert(num_cols == #M, num_cols)
  local chunk_idx = 0
  repeat 
    local n 
    for k, v in pairs(T) do 
      -- print("getting chunk " .. chunk_idx .. " for " .. k)
      if ( chunk_idx > 0 ) then print(">>>> START Deliberate error") end 
      n = v:get_chunk(chunk_idx)
      if ( chunk_idx > 0 ) then print(">>>> STOP  Deliberate error") end 
      if  ( n ~= 0 ) then 
        v:unget_chunk(chunk_idx)
      end
      -- print("got    chunk " .. chunk_idx .. " for " .. k)
    end
    chunk_idx = chunk_idx + 1
  until (n == 0)
  -- This test is specific to the in1.csv we have crafted
  for i = 1, T.i4:num_elements() do
    assert(T.i4:get1(i-1):to_num() == i)
  end
  for i = 1, T.f4:num_elements() do
    assert(math.ceil( T.f4:get1(i-1):to_num()) == i+1)
    assert(math.floor(T.f4:get1(i-1):to_num()) == i)
  end
  --===================
  if ( test_print ) then
    local opfile = "/tmp/_x"
    for _, impl in ipairs({"C", "L"}) do 
      local U = {}
      U[1] = T.i4
      U[2] = T.f4
      Q.print_csv(U, { impl = impl, opfile = opfile } )
      local expected = qcfg.q_src_root .. 
        "/OPERATORS/LOAD_CSV/test/chk_in1.csv"
      assert(plutils.readfile(expected) == plutils.readfile(opfile),
        "mismatch between " .. expected .. " and " .. opfile)

      print("Tested print with impl = ", impl)
    end
  end
  --===================
  assert(cVector.check_all())
  T.i4:delete()
  T.f4:delete()
  assert(lgutils.mem_used() == 0)
  assert(lgutils.dsk_used() == 0)
  collectgarbage("restart")
  assert(cVector.check_all())
  print("Test t1 succeeded")
end
--=======================================================
tests.t2 = function()
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local M = {}
  local O = { is_hdr = true }
  M[1] = { name = "i1", qtype = "I4", has_nulls = false }
  M[2] = { name = "s1", qtype = "SC", has_nulls = false, width = 6}
  local datafile = qcfg.q_src_root .. "/OPERATORS/LOAD_CSV/test/in2.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  assert(type(T) == "table")
  for k, v in ipairs(M) do 
    assert(type(T[v.name]) == "lVector")
  end
  local chunk_idx = 0
  for k, v in pairs(T) do 
    assert(type(v) == "lVector")
    if ( k == "i1" ) then assert(v:qtype() == "I4") end 
    if ( k == "s1" ) then assert(v:qtype() == "SC") end 
  end
  repeat 
    local n 
    for k, v in pairs(T) do 
      if ( chunk_idx > 0 ) then print(">>>> START Deliberate error") end 
      n = v:get_chunk(chunk_idx)
      if ( chunk_idx > 0 ) then print("<<<< STOP  Deliberate error") end 
      if ( n > 0 ) then 
        v:unget_chunk(chunk_idx)
      end
    end
    print("Completed " .. chunk_idx )
    chunk_idx = chunk_idx + 1
  until n == 0 
  T.s1:get1(0)
  -- This test is specific to the in2.csv we have crafted
  assert(T.i1:get1(0) == Scalar.new(10, "I4"))
  assert(T.i1:get1(1) == Scalar.new(20, "I4"))
  assert(T.i1:get1(2) == Scalar.new(30, "I4"))
  for i = 1, T.s1:num_elements() do
    assert(type(T.s1:get1(i-1)) == "Scalar")
  end
  assert(T.s1:get1(0):to_str() == "ABC")
  assert(T.s1:get1(1):to_str() == "DEFX")
  assert(T.s1:get1(2):to_str() == "GHIYZ")
  --===================
  if ( test_print ) then
    local opfile = "/tmp/_x"
    for _, impl in ipairs({"C", "L"}) do 
      local U = {}
      U[1] = T.i1
      U[2] = T.s1
      Q.print_csv(U, { impl = impl, opfile = opfile } )
      local expected = qcfg.q_src_root .. "/OPERATORS/LOAD_CSV/test/chk_in2.csv"
      assert(plutils.readfile(expected) == plutils.readfile(opfile))
    end
  end
  assert(cVector.check_all())
  assert(T.i1:delete())
  assert(T.s1:delete())
  assert(cVector.check_all())
  assert(lgutils.mem_used() == 0)
  assert(lgutils.dsk_used() == 0)
  collectgarbage("restart")
  assert(cVector.check_all())
  print("Test t2 succeeded")
end
--=======================================================
tests.t3 = function()
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local M = {}
  local O = { is_hdr = true, fld_sep = "comma", memo_len = -1  }
  M[#M+1] = { is_memo = false, name = "datetime", qtype = "SC", width=20}
  M[#M+1] = { is_memo = false, name = "store_id", qtype = "I4", }
  M[#M+1] = { is_memo = false, name = "customer_id", qtype = "I8", }
  M[#M+1] = { is_memo = false, name = "category_id", qtype = "I4", }
  M[#M+1] = { is_memo = true, name = "price", qtype = "F4", has_nulls = false}
  local datafile = qcfg.q_src_root .. "/OPERATORS/LOAD_CSV/test/in3.csv"
  assert(plpath.isfile(datafile))
  local x = cutils.num_lines(datafile)
  local y = x / qcfg.max_num_in_chunk
  local T = Q.load_csv(datafile, M, O)
  for _, v in pairs(T) do assert(v:memo_len() == -1 ) end 
  local chunk_idx = 0
  repeat 
    local n 
    for k, v in pairs(T) do 
      if ( chunk_idx > y ) then print(">>>> START Deliberate error") end 
      n = v:get_chunk(chunk_idx)
      if ( chunk_idx > y ) then print(">>>> STOP  Deliberate error") end 
      if ( n > 0 ) then 
        v:unget_chunk(chunk_idx)
      end
    end
    chunk_idx = chunk_idx + 1
  until n == 0 
  --==============
  if ( test_print ) then 
    local opfile = "/tmp/_x"
    for _, impl in ipairs({"C", "L"}) do 
      local U = {}
      local i = 1
      for _, v in pairs(T) do U[i] = v; i = i + 1 end 
      Q.print_csv(U, {opfile = opfile, impl = impl})
    end
  end
  assert(cVector.check_all())
  for _, v in pairs(T) do assert(v:delete()) end
  assert(cVector.check_all())
  assert(lgutils.mem_used() == 0)
  assert(lgutils.dsk_used() == 0)
  collectgarbage("restart")
  assert(cVector.check_all())
  print("Test t3 succeeded")
end
--==============================================================
tests.t4 = function()
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "datetime", qtype = "SC", has_nulls = false, width=20}
  M[#M+1] = { name = "store_id", qtype = "I4", has_nulls = false}
  local format = "%Y-%m-%d %H:%M:%S"
  local datafile = qcfg.q_src_root .. "/OPERATORS/LOAD_CSV/test/in4.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  T.datetime:eval()
  T.datetime:pr("_1", 0, 0, format); 
  T.store_id:pr("_2", 0, 0, format); 
  assert(cVector.check_all())
  local x = Q.SC_to_TM(T.datetime, format):set_name("x")
  assert(type(x) == "lVector")
  x:eval()
  if ( T.datetime:has_nulls() ) then assert(x:has_nulls()) end 
  if ( not T.datetime:has_nulls() ) then assert(not x:has_nulls()) end 
  assert(x:check())
  assert(x:num_elements() == T.datetime:num_elements())
  x:pr("_3", 0, 0, format); 
  local y = Q.TM_to_SC(x, format):set_name("y")
  y:eval()
  assert(y:check())
  y:pr("_4", 0, 0, format); 
  local out1 = plfile.read("_1")
  local out3 = plfile.read("_3")
  local out4 = plfile.read("_4")
  assert(out1 == out3)
  assert(out1 == out4)
  --===================
  if ( test_print ) then
    for _, impl in ipairs({"C", "L"}) do 
      local opfile = "/tmp/_x" .. impl
      local U = {}
      U[1] = T.datetime
      U[2] = T.store_id
      Q.print_csv(U, 
      { opfile = opfile, impl = impl, header = "datetime,store_id", })
      local expected = qcfg.q_src_root .. 
      "/OPERATORS/LOAD_CSV/test/chk_in4.csv"
      assert(plutils.readfile(expected) == plutils.readfile(opfile), 
      "Mismatch in " .. expected .. " and " .. opfile)
    end
  end
  --===================
  assert(cVector.check_all())
  for k, v in pairs(T) do v:delete() end 
  x:delete()
  y:delete()
  assert(lgutils.mem_used() == 0)
  assert(lgutils.dsk_used() == 0)
  collectgarbage("restart")
  assert(cVector.check_all())
  print("Test t4 succeeded")
end
--==============================================================
tests.t4a = function()
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "datetime", qtype = "SC", has_nulls = false, width=20}
  M[#M+1] = { name = "store_id", qtype = "I4", has_nulls = false}
  local format = "%Y-%m-%d %H:%M:%S"
  local datafile = qcfg.q_src_root .. "/OPERATORS/LOAD_CSV/test/in4.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  T.datetime:set_name("datetime")
  local x = Q.SC_to_TM(T.datetime, format)
  x:set_name("xvec")
  assert(type(x) == "lVector")
  local y = Q.TM_to_SC(x, format)
  y:set_name("yvec")
  y:eval()
  y:pr("_4a", 0, 0, format); 
  --===================
  if ( test_print ) then
    for _, impl in ipairs({"C", "L"}) do 
      local opfile = "/tmp/_x" .. impl
      local U = {}
      U[1] = T.datetime
      U[2] = T.store_id
      Q.print_csv(U, 
      { opfile = opfile, impl = impl, header = "datetime,store_id", })
      local expected = qcfg.q_src_root .. 
      "/OPERATORS/LOAD_CSV/test/chk_in4.csv"
      assert(plutils.readfile(expected) == plutils.readfile(opfile), 
      "Mismatch in " .. expected .. " and " .. opfile)
    end
  end
  --===================
  assert(cVector.check_all())
  for k, v in pairs(T) do v:delete() end 
  x:delete()
  y:delete()
  assert(lgutils.mem_used() == 0)
  assert(lgutils.dsk_used() == 0)
  collectgarbage("restart")
  assert(cVector.check_all())
  print("Test t4a succeeded")
end
tests.t5 = function()
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local M = {}
  local O = { is_hdr = true, memo_len = -1  }
  M[#M+1] = { name = "datetime", qtype = "SC", has_nulls = false, width=20}
  M[#M+1] = { is_load = false, name = "store_id", qtype = "I4", has_nulls = false}
  M[#M+1] = { is_load = false, name = "customer_id", qtype = "I8", has_nulls = false}
  M[#M+1] = { is_load = false, name = "category_id", qtype = "I4", has_nulls = false}
  M[#M+1] = { is_load = false, name = "price", qtype = "F4", has_nulls = false}
  local format = "%Y-%m-%d %H:%M:%S"
  local datafile = qcfg.q_src_root .. "/OPERATORS/LOAD_CSV/test/in3.csv"
  assert(plpath.isfile(datafile))
  local nx = cutils.num_lines(datafile)
  local ny = nx / qcfg.max_num_in_chunk

  local T = Q.load_csv(datafile, M, O)
  assert(T.datetime) 
  assert(cVector.check_all())
  local x = Q.SC_to_TM(T.datetime, format):set_name("out_datetime")

  assert(cVector.check_all())

  local tm_flds = { 
  "tm_sec",
  "tm_min",
  "tm_hour",
  "tm_mday",
  "tm_mon",
  "tm_year",
  "tm_wday",
  "tm_yday",
  "tm_isdst",
  }
  local out = {}
  for i, tm_fld in ipairs(tm_flds) do 
    out[i] = Q.TM_to_I2(x, tm_fld):set_name("out_" ..tm_fld)
    assert(type(out[i]) ==  "lVector")
  end
  assert(cVector.check_all())
  for i, tm_fld in ipairs(tm_flds) do out[i]:eval() end -- TODO 
  assert(cVector.check_all())

  local chunk_idx = 0
  local n
  repeat 
    for _, v in ipairs(out) do 
      if ( chunk_idx >= ny ) then print("START DELIBERATE ERROR") end 
      n = v:get_chunk(chunk_idx)
      if ( chunk_idx >= ny ) then print("STOP  DELIBERATE ERROR") end 
      if ( n > 0 ) then 
        v:unget_chunk(chunk_idx)
      end
    end
    chunk_idx = chunk_idx + 1 
  until n == 0 
  -- print values 
  for i, tm_fld in ipairs(tm_flds) do 
    out[i]:pr("_" .. tm_fld, 0, 0, format); 
  end
  -- check with correct values
  for i, tm_fld in ipairs(tm_flds) do 
    local x = plfile.read(tm_fld)
    local y = plfile.read("_" .. tm_fld)
    assert(x == y, "Difference for file " .. tm_fld)
  end

  if ( test_print ) then 
    for _, impl in ipairs({"C", "L", }) do  
      local opfile = "/tmp/_x" .. impl
      Q.print_csv(out, {opfile = opfile, impl = impl})
      local expected = qcfg.q_src_root .. 
      "/OPERATORS/LOAD_CSV/test/chk_in5.csv"
      assert(plutils.readfile(expected) == plutils.readfile(opfile),
        "Discrepancy between " .. expected .. " and " .. opfile)
      print("Tested print with impl = " .. impl)
    end
  end
  assert(cVector.check_all())
  for k, v in pairs(T) do v:delete() end 
  for k, v in pairs(out) do v:delete() end 
  x:delete()
  assert(lgutils.mem_used() == 0)
  assert(lgutils.dsk_used() == 0)
  collectgarbage("restart")
  assert(cVector.check_all())
  print("Test t5 succeeded")
end
-- Testing null values
tests.t6 = function() 
  collectgarbage("stop")
  assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
  local datafile = qcfg.q_src_root .. "/OPERATORS/LOAD_CSV/test/in6.csv"
  assert(plpath.isfile(datafile))
  -- TODO P2 Implement B1 for _, nn_qtype in ipairs( { "B1", "BL", } ) do 
  for _, nn_qtype in ipairs( { "BL", } ) do 
    print("Testing with nn_qtype = ", nn_qtype)
    local O = { is_hdr = true, memo_len = -1, nn_qtype = nn_qtype, }
    local M = {}
    M[#M+1] = { name = "i4", qtype = "I4", has_nulls = true, }
    M[#M+1] = { name = "f4", qtype = "F4", has_nulls = true, }
    local T = Q.load_csv(datafile, M, O)

    assert(T.i4:has_nulls() == true)
    assert(T.f4:has_nulls() == true)
  
    T.i4:eval() 
    -- eval() need to evaluate because we cannot mess with nulls until eov 

    local nn_i4 = T.i4:get_nulls()
    assert(type(nn_i4) == "lVector")
    assert(nn_i4:qtype() == nn_qtype)
    T.i4:set_nulls(nn_i4) -- because get_nulls breaks connection
  
    local nn_f4 = T.f4:get_nulls()
    assert(type(nn_f4) == "lVector")
    assert(nn_f4:qtype() == nn_qtype)
    T.f4:set_nulls(nn_f4) -- because get_nulls breaks connection

    T.i4:check()
    T.i4:pr("/tmp/_i4")
    T.f4:pr("/tmp/_f4")
    T.i4:check()

    local r = Q.sum(nn_i4)
    local n1, n2 = r:eval()
    r:delete()
    assert(n1:to_num() == 6 )
    assert(n2:to_num() == 11 )

    local r = Q.sum(nn_f4)
    local n1, n2 = r:eval()
    r:delete()
    assert(n1:to_num() == 6 )
    assert(n2:to_num() == 11 )

    local U = {}
    U[1] = T.i4
    U[2] = T.f4
    U[3] = T.i4
    U[4] = T.f4
    T.i4:check()
    local opfile = "/tmp/_xxx"
    Q.print_csv(U, { impl = "C", opfile = opfile } )
    --=====================================
    assert(cVector.check_all())
    for k, v in pairs(T) do v:delete() end 
    assert(lgutils.mem_used() == 0)
    assert(lgutils.dsk_used() == 0)
    collectgarbage("restart")
    assert(cVector.check_all())
    print("Test t6 succeeded for nn_qtype = ", nn_qtype)
  end
  
end
tests.t1()
tests.t2()
tests.t3()
tests.t4()
tests.t4a()
tests.t5()
tests.t6()
-- return tests
collectgarbage()
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
