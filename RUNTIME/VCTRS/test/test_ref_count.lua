local Q = require 'Q'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local qcfg = require 'Q/UTILS/lua/qcfg'
local tests = {}
tests.t1 = function()
  local x = lVector({ qtype = "F4", width = 4})
  assert(x:ref_count() == 1)
  local x_uqid = x:uqid()
  assert(x_uqid == 1)
  local y = lVector({uqid = x_uqid})
  assert(type(y) == "lVector")
  local y_uqid = y:uqid()
  print(y_uqid, x_uqid)
  assert(y_uqid == x_uqid)
  assert(y:ref_count() == 2)
  x = nil
  collectgarbage()
  assert(y:ref_count() == 1)
  print("Test t1 succeeded")
end
tests.t2 = function()
  -- create a vector 
  local x = lVector({ qtype = "F4", width = 4})
  assert(type(x) == "lVector")
  local n = 10
  for i = 1, n do
    local s = Scalar.new(i+1, "F4")
    assert(type(s) == "Scalar")
    x:put1(s)
  end
  x:eov()
  assert(cVector:count() == 1)
  -- create a nnn vector for it 
  local nn_x = lVector({ qtype = "BL"})
  assert(type(nn_x) == "lVector")
  local n = 10
  for i = 1, n do
    local s = Scalar.new(true, "BL")
    assert(type(s) == "Scalar")
    nn_x:put1(s)
  end
  nn_x:eov()
  assert(cVector:count() == 2)
  -- associate nn_x with x 
  x:set_nulls(nn_x)
  assert(x:has_nulls())
  -- extract nn_x from x multiple times
  local Y = {}
  for i = 1, 10000 do 
    Y[i] = x:get_nulls()
    assert(type(Y[i]) == "lVector")
    assert(cVector:count() == 2)
  end
  print("Test t2 succeeded")
end
-- return tests
-- WORKS tests.t1()
tests.t2()
