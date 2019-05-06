-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q'
local Scalar = require 'libsclr'
local tests = {}
tests.t1 = function()
  local x = Q.mk_col({10, 20, 30, 40, 50, 60, 70, 80}, 'I4')
  -- print(type(x))
  -- print(x:length())
  Q.sort(x, "dsc")
  --Q.print_csv(x) 
  local val = Q.max(x):eval()
  for i = 1, x:length() do
    assert(x:get_one(i-1) == val)
    val = val - Scalar.new(10, "I4")
  end
  print("Test t1 succeeded")
  -- save = require 'Q/UTILS/lua/save'
  -- save('tmp.save')
end
tests.t2 = function()
  local x = Q.seq({ len = 8, start = 10, by = 10, qtype = "I4"})
  -- print(type(x))
  -- print(x:length())
  Q.sort(x, "dsc")
  -- Q.print_csv(x, { opfile = "" })
  local val = Q.max(x):eval()
  for i = 1, x:length() do
    assert(x:get_one(i-1) == val)
    val = val - Scalar.new(10, "I4")
  end
  print("Test t2 succeeded")
  -- save = require 'Q/UTILS/lua/save'
  -- save('tmp.save')
end
return tests
