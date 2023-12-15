-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local from_scalar = require 'Q/UTILS/lua/from_scalar'
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
  cVector.check_all(true, true)
  print("Test t1 succeeded")
end   
tests.t2 = function()
  -- make vector with null values
  local col = Q.mk_col({1,2,3,4}, "I4", 
    { name = "my test name"}, {true, false, true, false})
  assert(type(col) == "lVector")
  assert(col:has_nulls() == true)
  assert(col:name() == "my test name")
  local uqid = col:uqid()
  assert(col:qtype() == "I4")
  --===================================
  local nn_col = assert(col:get_nulls()) 
  assert(type(nn_col) == "lVector")
  assert(nn_col:has_nulls() == false)
  local nn_uqid = nn_col:uqid()
  assert(nn_col:qtype() == "BL")
  col:set_nulls(nn_col) ---  because get_nulls is breaking 
  --=====================================
  assert(nn_col:num_elements() == col:num_elements())
  for i = 1, col:num_elements() do  
    local x, nn_x = col:get1(i-1)
    assert(type(x) == "Scalar")
    assert(type(nn_x) == "Scalar")
    if ( ( i == 1 ) or ( i == 3 ) ) then 
      assert(nn_x == Scalar.new(true, "BL"))
    elseif ( ( i == 2 ) or ( i == 4 ) ) then 
      assert(nn_x == Scalar.new(false, "BL"))
    else
      error("")
    end
  end
  assert(col:has_nulls())
  cVector.check_all(true, true)
  print("Test t2 succeeded")
end   
tests.test_mk_tbl = function()
  -- input table of values 1,2,3 of type I4, given to mk_col
  local qtype = "I4"
  local intbl = { 1, 2, 3, 4 } 
  local col = assert(Q.mk_col(intbl, qtype))
  local tbl = assert(Q.mk_tbl(col))
  assert(type(tbl) == "table")
  assert(#tbl == #intbl)
  for i = 1, #tbl do 
    tbl[i] = from_scalar(tbl[i])
    assert(type(tbl[i]) == type(intbl[i]))
    assert(tbl[i] == intbl[i])
  end
  print("Test test_mk_tbl succeeded")
end   
-- return tests
tests.t1()
tests.t2()
tests.test_mk_tbl()
