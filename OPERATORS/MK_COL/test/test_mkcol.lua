-- FUNCTIONAL

local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
local convert_c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local tests = {}
tests.t1 = function()
  -- input table of values 1,2,3 of type I4, given to mk_col
  local col = mk_col({1,3,4}, "I4")
  assert(col)
  assert(type(col) == "lVector", " Output of mk_col is not lVector")
  for i=1, col:length() do  
    local status, result = pcall(convert_c_to_txt, col, i)
    assert(status, "Failed to get the value from vector at index: "..tostring(i))
    if result == nil then result = "" end
  end
  assert(col:has_nulls() == false)
  print("Test t1 succeeded")
end   
tests.t2 = function()
  -- make vector with null values
  local col = mk_col({1,2,3,4}, "I4", {true, false, true, false})
  assert(col)
  assert(type(col) == "lVector", " Output of mk_col is not lVector")
  for i=1, col:length() do  
    local status, result = pcall(convert_c_to_txt, col, i)
    assert(status, "Failed to get the value from vector at index: "..tostring(i))
    if result == nil then result = "" end
  end
  assert(col:has_nulls())
  -- TODO assert(Q.sum(col):eval():to_num() == 1+3)
  print("Test t2 succeeded")
end   
return tests
