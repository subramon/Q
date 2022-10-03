local Q       = require 'Q'
local ffi     = require 'ffi'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local Scalar  = require 'libsclr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local plpath = require 'pl.path'
local plutils= require 'pl.utils'
local plfile = require 'pl.file'
require 'Q/UTILS/lua/strict'
-- TODO P1 Set below to true 
local test_print  = true -- turn false if you want only load_csv tested
--=======================================================
local tests = {}
tests.t1 = function()
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
    -- if ( chunk_idx == 9 ) then break end -- TODO P1 
    local n 
    for k, v in pairs(T) do 
      n = v:get_chunk(chunk_idx)
      if  ( n ~= 0 ) then 
        v:unget_chunk(chunk_idx)
      end
      -- print("got chunk " .. chunk_idx .. " for " .. k)
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
  print("Test t1 succeeded")
end
--=======================================================
tests.t2 = function()
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
      n = v:get_chunk(chunk_idx)
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
  print("Test t2 succeeded")
end
--=======================================================
tests.t3 = function()
  local M = {}
  local O = { is_hdr = true, fld_sep = "comma", memo_len = -1  }
  M[#M+1] = { is_memo = false, name = "datetime", qtype = "SC", width=20}
  M[#M+1] = { is_memo = false, name = "store_id", qtype = "I4", }
  M[#M+1] = { is_memo = false, name = "customer_id", qtype = "I8", }
  M[#M+1] = { is_memo = false, name = "category_id", qtype = "I4", }
  M[#M+1] = { is_memo = true, name = "price", qtype = "F4", has_nulls = false}
  local datafile = qcfg.q_src_root .. "/OPERATORS/LOAD_CSV/test/in3.csv"
  assert(plpath.isfile(datafile))
  local T = Q.load_csv(datafile, M, O)
  for _, v in pairs(T) do assert(v:memo_len() == -1 ) end 
  local chunk_idx = 0
  repeat 
    local n 
    for k, v in pairs(T) do 
      n = v:get_chunk(chunk_idx)
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
  print("Test t3 succeeded")
end
--==============================================================
tests.t4 = function()
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
  local x = Q.SC_to_TM(T.datetime, format)
  x:eval()
  assert(type(x) == "lVector")
  assert(x:num_elements() == T.datetime:num_elements())
  x:pr("_3", 0, 0, format); 
  local y = Q.TM_to_SC(x, format)
  y:eval()
  x:pr("_4", 0, 0, format); 
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
  print("Test t4 succeeded")
end
--==============================================================
tests.t4a = function()
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
  print("Test t4a succeeded")
end
tests.t5 = function()
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
  local T = Q.load_csv(datafile, M, O)
  assert(T.datetime) 
  local x = Q.SC_to_TM(T.datetime, format)

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
    out[i] = Q.TM_to_I2(x, tm_fld)
    assert(type(out[i]) ==  "lVector")
  end
  local chunk_idx = 0
  local n
  repeat 
    for _, v in ipairs(out) do 
      n = v:get_chunk(chunk_idx)
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
    assert(x == y)
  end

  if ( test_print ) then 
    for _, impl in ipairs({"C", "L"}) do 
      local opfile = "/tmp/_x" .. impl
      Q.print_csv(out, {opfile = opfile, impl = impl})
      local expected = qcfg.q_src_root .. 
      "/OPERATORS/LOAD_CSV/test/chk_in5.csv"
      assert(plutils.readfile(expected) == plutils.readfile(opfile))
    end
  end
  -- TODO P3 verify that fields correctly extracted
  print("Test t5 succeeded")
end
-- Testing null values
tests.t6 = function() 
  local datafile = qcfg.q_src_root .. "/OPERATORS/LOAD_CSV/test/in6.csv"
  assert(plpath.isfile(datafile))
  for _, nn_qtype in ipairs( { "B1", "BL", } ) do 
    local O = { is_hdr = true, memo_len = -1, nn_qtype = nn_qtype, }
    local M = {}
    M[#M+1] = { name = "i4", qtype = "I4", nn_qtype = "B1", has_nulls = true, }
    M[#M+1] = { name = "f4", qtype = "F4", nn_qtype = "BL", has_nulls = true, }
    local T = Q.load_csv(datafile, M, O)
    assert(T.i4:has_nulls() == true)
    assert(T.f4:has_nulls() == true)
  
    local nn_i4 = T.i4:get_nulls()
    assert(type(nn_i4) == "lVector")
    assert(nn_i4:qtype() == nn_qtype)
  
    local nn_f4 = T.f4:get_nulls()
    assert(type(nn_f4) == "lVector")
    assert(nn_f4:qtype() == nn_qtype)
  
    print("-------------")
    T.i4:eval()
    T.i4:pr()
    T.f4:pr()
    local U = {}
    U[1] = T.i4
    U[2] = T.f4
    U[3] = T.i4
    U[4] = T.f4
    local opfile = "/tmp/_xxx"
    Q.print_csv(U, { impl = "C", opfile = opfile } )
  end
  print("Test t6 succeeded")
  
end
-- WORKS tests.t1()
-- WORKS tests.t2()
-- TODO tests.t3()
-- WORKS tests.t4()
-- WORKS tests.t4a()
-- tests.t5()
tests.t6()
os.exit()
return tests
--]]
