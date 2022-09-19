-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local Scalar  = require 'libsclr'
local tests = {}
tests.t1 = function()
  -- input table of values 1,2,3 of type I4, given to mk_col
  local qtype = "I4"
  local col = assert(Q.mk_col({1,2,3,4}, qtype))
  assert(type(col) == "lVector")
  for i = 1, col:num_elements() do  
    local x = col:get1(i-1)
    assert(type(x) == "Scalar")
    assert(x:qtype() == qtype)
    assert(x == Scalar.new(i, "I4")) -- dependent on input values
  end
  assert(col:has_nulls() == false)
  print("Test t1 succeeded")
end   
tests.t2 = function()
  -- make vector with null values
  local col = Q.mk_col({1,2,3,4}, "I4", {true, false, true, false})
  assert(type(col) == "lVector", " Output of mk_col is not lVector")
  for i = 1, col:num_elements() do  
    local x, nn_x = col:get1(i-1)
    assert(type(x) == "Scalar")
    assert(type(nn_x) == "Scalar")
    if ( ( i == 1 ) or ( i == 3 ) ) then 
      assert(nn_x == Scalar.new(true, "B1"))
    elseif ( ( i == 2 ) or ( i == 4 ) ) then 
      assert(nn_x == Scalar.new(false, "B1"))
    else
      error("")
    end
  end
  assert(col:has_nulls())
  print("Test t2 succeeded")
end   
-- return tests
tests.t1()
tests.t2()
