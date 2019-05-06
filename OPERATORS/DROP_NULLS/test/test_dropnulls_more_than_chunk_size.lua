-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local Scalar = require 'libsclr' ; 

local tests = {}
tests.t1 = function()
  --=============================
  local input_table_I4 = {}
  local input_table_B1 = {}
  
  for i = 1, 65540 do
    input_table_I4[i] = i * 1
    local value 
    if i % 2 == 0 then value = 0 else value = 1 end
    input_table_B1[i] = value
  end
  
  local x = Q.mk_col(input_table_I4, "I4")
  local y = Q.mk_col(input_table_B1, "B1")
  local sval = Scalar.new("10", "I4")
  x:make_nulls(y)
  local z = Q.drop_nulls(x, sval) 
  assert(Q.sum(z):eval():to_num() == 1074200600)
  print("Test t1 succeeded")
end
return tests
