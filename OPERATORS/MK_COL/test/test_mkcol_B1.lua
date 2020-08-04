-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Scalar = require 'libsclr'
local mk_col = require 'Q/OPERATORS/MK_COL/lua/mk_col'

local tests = {}
tests.t1 = function() 
  local input = {1,0,0,0,1,1,0,1,0}
  local col  =  mk_col(input, "B1")
  assert(type(col) == "lVector", " Output of mk_col is not lVector")
  assert(col:num_elements() == #input)
  for i = 1, col:length() do
    local s = Scalar.new(input[i], "B1")
    assert(col:get1(i-1) == s)
  end
  print("Test t1 succeeded")
end
tests.t2 = function() 
  local input = {true, false, true, false}
  local col  =  mk_col(input, "B1")
  assert(col)
  assert(type(col) == "lVector", " Output of mk_col is not lVector")
  for i=1,col:length() do
    local x = col:get1(i-1)
    assert(x)
    assert(type(x) == "Scalar")
    assert(x:to_str() == tostring(input[i]))
  end
  print("Test t2 succeeded")
end
-- tests.t1()
return tests
