local cVector = require 'libvctr'
local Scalar  = require 'libsclr'
cVector.init_globals({})
local Q = require 'Q'
local tests = {}
local plfile = require 'pl.file'
local plpath = require 'pl.path'
--=======================================================
tests.t1 = function()
  local M = {}
  local O = { is_hdr = true }
  M[1] = { name = "i4", qtype = "I4", is_memo = false}
  M[2] = { name = "f4", qtype = "F4", is_memo = true}
  local datafile = "in1.csv"
  local T = Q.load_csv(datafile, M, O)
  local num_cols = 0
  assert(type(T) == "table")
  for k, v in pairs(T) do 
    num_cols = num_cols + 1
    assert(type(v) == "lVector")
    if ( k == "i4" ) then 
      assert(v:fldtype() == "I4") 
    elseif ( k == "f4" ) then 
      assert(v:fldtype() == "F4") 
    else
      error("")
    end 
  end
  assert(num_cols == #M, num_cols)
  local chunk_idx = 0
  repeat 
    local n 
    for k, v in pairs(T) do 
      n = v:get_chunk(chunk_idx)
      if  ( n ~= 0 ) then 
        v:unget_chunk(chunk_idx)
      end
    end
    chunk_idx = chunk_idx + 1
  until n == 0 
  -- This test is specific to the in1.csv we have crafted
  for i = 1, T.i4:num_elements() do
    assert(T.i4:get1(i-1) == Scalar.new(i, "I4"))
  end
  for i = 1, T.f4:num_elements() do
    assert(math.ceil( T.f4:get1(i-1):to_num()) == i+1)
    assert(math.floor(T.f4:get1(i-1):to_num()) == i  )
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
  local datafile = "in2.csv"
  local T = Q.load_csv(datafile, M, O)
  assert(type(T) == "table")
  for k, v in ipairs(M) do 
    assert(type(T[v.name]) == "lVector")
  end
  print("xxxxxxxxxxx")
  local chunk_idx = 0
  for k, v in pairs(T) do 
    assert(type(v) == "lVector")
    if ( k == "i1" ) then assert(v:fldtype() == "I4") end 
    if ( k == "s1" ) then assert(v:fldtype() == "SC") end 
  end
  repeat 
    local n 
    for k, v in pairs(T) do 
      n = v:chunk(chunk_idx)
    end
    print("Completed " .. chunk_idx )
    chunk_idx = chunk_idx + 1
  until n == 0 
  print("Completed load")
  Q.print_csv(T)
  print("Test t2 succeeded")
end
--=======================================================
tests.t3 = function()
  local M = {}
  local O = { is_hdr = true, fld_sep = "comma" }
  M[#M+1] = { is_memo = false, name = "datetime", qtype = "SC", width=20}
  M[#M+1] = { is_memo = false, name = "store_id", qtype = "I4", }
  M[#M+1] = { is_memo = false, name = "customer_id", qtype = "I8", }
  M[#M+1] = { is_memo = false, name = "category_id", qtype = "I4", }
  M[#M+1] = { is_memo = true, name = "price", qtype = "F4", has_nulls = false}
  local datafile = "in3.csv"
  local T = Q.load_csv(datafile, M, O)
  local chunk_idx = 0
  repeat 
    local n 
    for k, v in pairs(T) do 
      n = v:chunk(chunk_idx)
    end
    chunk_idx = chunk_idx + 1
  until n == 0 
  local opfile = '_x.csv'
  plfile.delete(opfile)
  Q.print_csv(T.price, { lb = 0, ub = 10, opfile = opfile})
  assert(plpath.isfile(opfile))
  print("Test t3 succeeded")
end
tests.t4 = function()
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "datetime", qtype = "SC", has_nulls = false, width=20}
  M[#M+1] = { name = "store_id", qtype = "I4", has_nulls = false}
  local datafile = "in4.csv"
  local format = "%Y-%m-%d %H:%M:%S"
  local T = Q.oad_csv(datafile, M, O)
  local x = Q.SC_to_TM(T.datetime, format)
  local y = Q.TM_to_SC(x:eval(), format)
  -- Q.print_csv({T.datetime, y})
  -- TODO P3 verify that x and T.datetime are the same
  print("Test t4 succeeded")
end
tests.t5 = function()
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "datetime", qtype = "SC", has_nulls = false, width=20}
  M[#M+1] = { is_load = false, name = "store_id", qtype = "I4", has_nulls = false}
  M[#M+1] = { is_load = false, name = "customer_id", qtype = "I8", has_nulls = false}
  M[#M+1] = { is_load = false, name = "category_id", qtype = "I4", has_nulls = false}
  M[#M+1] = { is_load = false, name = "price", qtype = "F4", has_nulls = false}
  local datafile = "in3.csv"

  local format = "%Y-%m-%d %H:%M:%S"
  local T = Q.load_csv(datafile, M, O)
  for k, v in pairs(T) do print(k, v) end 
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
    for i, tm_fld in ipairs(tm_flds) do 
      n = out[i]:chunk(chunk_idx)
    end
    print("Chunk", chunk_idx)
    chunk_idx = chunk_idx + 1 
  until n == 0 

  -- Q.print_csv(out)
  -- TODO P3 verify that fields correctly extracted
  print("Test t5 succeeded")
end
tests.t1()
os.exit()
--[[
tests.t2()
tests.t3()
tests.t4()
tests.t5()
return tests
--]]
