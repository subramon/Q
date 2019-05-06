-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local qconsts = require 'Q/UTILS/lua/q_consts'
local a = Q.mk_col({10, 20, 30, 40, 50}, "I4"):set_name("a")

local tests = {}
tests.t1 = function ()
  local b = Q.mk_col({1, 0, 0, 1, 0}, "B1")
  local out_table = {10, 40}
  local c = Q.where(a, b):eval()
  assert(c:length() == Q.sum(b):eval():to_num(), "Length Mismatch")

  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == out_table[i])
  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
  print("Test t1 succeeded")
end
--======================================
tests.t2 = function ()
  local b = Q.mk_col({0, 0, 0, 0, 0}, "B1"):set_name("b")
  print(a:length())
  print(b:length())
  assert(Q.where(a, b):set_name("c"):eval() == nil)
  print("Test t2 succeeded")
end
--======================================
tests.t3 = function ()
  local b = Q.mk_col({1, 1, 1, 1, 1}, "B1")
  local out_table = {10, 20, 30, 40, 50}
  local c = Q.where(a, b):eval()
  assert(c:length() == Q.sum(b):eval():to_num(), "Length Mismatch")
  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == out_table[i])
  end
  -- local opt_args = { opfile = "" }
  -- Q.print_csv(c, opt_args)
end
--======================================
tests.t4 = function ()
  local b = Q.mk_col({0, 0, 0, 0, 0}, "B1")
  b:set_meta("min", 0)
  b:set_meta("max", 0)
  local c = Q.where(a, b)
  assert(c == nil)
end
--======================================
tests.t5 = function ()
  local b = Q.mk_col({1, 1, 1, 1, 1}, "B1")
  b:set_meta("min", 1)
  b:set_meta("max", 1)
  local c = Q.where(a, b)
  assert(c == a)
end
--======================================
tests.t6 = function ()
  print("=======================================")
  -- more than chunk size values present in a and b

  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 65538} )
  local len = 65538
  local b_input_table = {}
  for i=1, len do
    b_input_table[i] = 0
  end
  b_input_table[2]   = 1
  b_input_table[4]   = 1
  b_input_table[6]   = 1
  b_input_table[len] = 1
  local b = Q.mk_col(b_input_table, "B1")
  --local a = Q.mk_col(a_input_table, "I4")
  local exp_c = Q.mk_col({2, 4, 6, len}, "I4")
  local n_expected = exp_c:length()
  
  
  local c = Q.where(a, b)
  c:eval()
  --Q.print_csv(a, { opfile = "/tmp/a_out.txt"} )
  --Q.print_csv(c, { opfile =  ""} ) 
  --Q.print_csv(b, { opfile =  "/tmp/b_out.txt"} )
  assert(c:length() == exp_c:length(), 
  "ERROR: Expected: " .. exp_c:length() .. " Actual: " .. c:length())
  --assert(c:length() == Q.sum(b):eval():to_num(), "Length Mismatch")
  print("cmax", Q.max(c):eval())
  print("cmin", Q.min(c):eval())
  print("csum", Q.sum(c):eval())

  -- Q.print_csv(c) -- causes seg fault
  for i = 1, c:length() do
    local actual_value = c:get_one(i-1):to_num()
    local exp_value = exp_c:get_one(i-1):to_num()
    print("actual   = ", actual_value)
    print("expected = ", exp_value)
    assert(actual_value == exp_value, 
      "ERROR: Position: " .. i .. " Expected: " .. exp_value .. " Got " .. actual_value)
  end
  print("Test t6 succeeded")
end
--======================================

tests.t7 = function ()
  print("=======================================")
  -- more than chunk size values present in a and b

  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = 65538} )
  a:eval()
  
  -- First chunk contains all 1
  local b_input_table = {}
  for i=1, 65538 do
    b_input_table[i] = 1
  end
  b_input_table[65537] = 0
  local b = Q.mk_col(b_input_table, "B1")

  local expected_out = {}
  for i = 1, 65536 do
    expected_out[i] = i
  end
  expected_out[65537] = 65538
  
  --Q.print_csv(a, { opfile = "/tmp/a_out.txt"} )
  --Q.print_csv(b, { opfile = "/tmp/b_out.txt"} )
  
  local c = Q.where(a, b)
  c:eval()
  
  assert(c:length() == #expected_out, "Length Mismatch, Expected: " .. #expected_out .. " Actual: " .. c:length())
  --assert(c:length() == Q.sum(b):eval():to_num(), "Length Mismatch")

  for i = 1, c:length() do
    local value = c_to_txt(c, i)
    assert(value == expected_out[i], "Value Mismatch, Expected: " .. expected_out[i] .. " Actual: " .. value)
  end
  print("Test t7 succeeded")
end
--=========================================

tests.t8 = function ()
  print("=======================================")
  -- more than chunk size values present in a and b
  local chunk_sz = qconsts.chunk_size
  local len = chunk_sz * 2 + 5
  local a = Q.seq( {start = 1, by = 1, qtype = "I4", len = len} )
  local b_input_table = {}
  local exp_table = {}
  for i=1, chunk_sz-1 do
    b_input_table[i] = 1
  end
  b_input_table[chunk_sz] = 0
  for i = chunk_sz+1, chunk_sz * 2 do
    b_input_table[i] = 0
  end
  for i = (chunk_sz * 2 + 1), len do
    b_input_table[i] = 1
  end

  local b = Q.mk_col(b_input_table, "B1")
  local n_expected = chunk_sz-1 + 5


  local c = Q.where(a, b)
  c:eval()
  --Q.print_csv(a, { opfile = "/tmp/a_out.txt"} )
  --Q.print_csv(c, { opfile = "/tmp/c_out.txt"} )
  --Q.print_csv(b, { opfile = "/tmp/b_out.txt"} )
  assert(c:length() == n_expected)

  print("Test t8 succeeded")
end

tests.t9 = function ()
  -- B1 vector with all zeros, should return nil
  local b = Q.mk_col({0, 0, 0, 0, 0}, "B1")
  local c = Q.where(a, b):eval()
  assert(c == nil)
  print("Test t9 succeeded")
end


return tests
