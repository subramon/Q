require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local tests = {}

-- does Lua's unpack() built-in function causes error,
-- if unpack (which is a keyword in Lua)used as Q operator name

-- 1) Q.unpack() operator to return table of scalar values & 
-- 2) Lua unpack() to return table values unpacked
tests.t1 = function()
  local vec = Q.mk_col({10,20,30,40,50}, "I1")
  
  -- calling Q.unpack which is a Q operator
  local tbl = Q.unpack(vec)
  -- verifying Q.unpack's behaviour
  assert( type(tbl) == "table" )
  assert( #tbl == 5 )
  for i = 1 , #tbl do
    assert(type(tbl[i]) == "Scalar")
    assert(tbl[i]:to_num() == i * 10)
  end
  
  -- calling unpack which is Lua's built-in function
  local val_1, val_2 = unpack({10, "dummy_str"})
  -- verifying Lua's unpack() behaviour
  assert(val_1 == 10, "Lua's unpack() function failed")
  assert(val_2 == "dummy_str", "Lua's unpack() function failed")
  
  print("successfully executed t1")
end

return tests
