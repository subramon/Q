local Q = require 'Q'
local tests = {}
--=======================================================
tests.t1 = function()
  local M = {}
  local O = { is_hdr = true }
  M[1] = { name = "i4", qtype = "I4", is_memo = false}
  M[2] = { name = "f4", qtype = "F4", is_memo = false}
  local datafile = "in1.csv"
  local T = Q.new_load_csv(datafile, M, O)
  local chunk_idx = 0
  for k, v in pairs(T) do 
    assert(type(v) == "lVector")
    if ( k == "i4" ) then assert(v:fldtype() == "I4") end 
    if ( k == "f4" ) then assert(v:fldtype() == "F4") end 
  end
  repeat 
    local n 
    for k, v in pairs(T) do 
      n = v:chunk(chunk_idx)
    end
    chunk_idx = chunk_idx + 1
  until n == 0 
  --Q.print_csv(T)
  -- get length of input
  local datafile = "in1.csv"
  local num_lines = 0
  for _ in io.lines(datafile) do -- 'filename.txt' do
    num_lines = num_lines + 1
  end
  num_lines = num_lines - 1 -- because of header
  -- check length of vectors
  for k, v in pairs(T) do
    assert(v:is_eov())
    assert(v:length() == num_lines)
  end
  print("Test t1 succeeded")
end
--=======================================================
tests.t2 = function()
  local M = {}
  local O = { is_hdr = true }
  M[1] = { name = "i1", qtype = "I4", has_nulls = false }
  M[2] = { name = "s1", qtype = "SC", has_nulls = false, width = 6}
  local datafile = "in2.csv"
  local T = Q.new_load_csv(datafile, M, O)
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
    chunk_idx = chunk_idx + 1
  until n == 0 
  Q.print_csv(T)
  print("Test t3 succeeded")
end
--=======================================================
tests.t3 = function()
  local M = {}
  local O = { is_hdr = true }
  M[#M+1] = { name = "datetime", qtype = "SC", has_nulls = false, width=20}
  M[#M+1] = { name = "store_id", qtype = "I4", has_nulls = false}
  M[#M+1] = { name = "customer_id", qtype = "I8", has_nulls = false}
  M[#M+1] = { name = "category_id", qtype = "I4", has_nulls = false}
  M[#M+1] = { name = "price", qtype = "F4", has_nulls = false}
  local datafile = "in3.csv"
  local T = Q.new_load_csv(datafile, M, O)
  local chunk_idx = 0
  repeat 
    local n 
    for k, v in pairs(T) do 
      n = v:chunk(chunk_idx)
    end
    chunk_idx = chunk_idx + 1
  until n == 0 
  Q.print_csv(T, { lb = 0, ub = 10, opfile = "_x.csv"})
  print("Test t3 succeeded")
end
-- tests.t1()
-- tests.t2()
tests.t3()
--return tests
