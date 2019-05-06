-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local convert_c_to_txt = require 'Q/UTILS/lua/C_to_txt'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'
-- input table of values 1,2,3 of type I4, given to mk_col

local tests = {}
tests.t1 = function() 
  local input = {1,0,0,0,1,1,0,1,0}
  local col  =  mk_col(input, "B1")
  assert(col)
  assert(type(col) == "lVector", " Output of mk_col is not lVector")
  for i=1,col:length() do
    local status, result = pcall(convert_c_to_txt, col, i)
    assert(status, "Failed to get the value from vector at index: "..tostring(i))
    if result == nil then result = 0 end
    assert(result == input[i], "Mismatch between input and column values")
  end
  print("Test t1 succeeded")
end
tests.t2 = function() 
  local input = {true, false, true, false}
  local col  =  mk_col(input, "B1")
  assert(col)
  assert(type(col) == "lVector", " Output of mk_col is not lVector")
  for i=1,col:length() do
    local x = col:get_one(i-1)
    assert(x)
    assert(type(x) == "Scalar")
    assert(x:to_str() == tostring(input[i]))
  end
  print("Test t2 succeeded")
end
return tests
