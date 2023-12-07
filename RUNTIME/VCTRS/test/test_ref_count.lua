local Q = require 'Q'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local Scalar  = require 'libsclr'
local cVector = require 'libvctr'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local lgutils = require 'liblgutils'
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
  assert(cVector.check_all())
  print("Test t1 succeeded")
end
tests.t2 = function()
  -- create a vector 
  local n1 = cVector.count(0); print("n1 = ", n1)
  local x = lVector({ qtype = "F4", width = 4})
  assert(type(x) == "lVector")
  local n = 10
  for i = 1, n do
    local s = Scalar.new(i+1, "F4")
    assert(type(s) == "Scalar")
    x:put1(s)
  end
  x:eov()
  local n2 = cVector.count(0); print("n2 = ", n2)
  assert(n2 == (n1+1))
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
  local n3 = cVector.count(0); print("n3 = ", n3)
  assert(n3 == (n2+1))
  -- associate nn_x with x 
  x:set_nulls(nn_x)
  assert(x:has_nulls())
  -- extract nn_x from x multiple times
  local Y = {}
  for i = 1, 10000 do 
    Y[i] = x:get_nulls()
    assert(type(Y[i]) == "lVector")
    local n4 = cVector.count(0); 
    assert(n4 == n3)
    x:set_nulls(Y[i])
    assert(x:has_nulls())
  end
  x:drop_nulls()
  assert(x:has_nulls() == false)
  x:drop_nulls()
  -- Y[1]:pr()
  assert(cVector.check_all())
  print("Test t2 succeeded")
end
-- return tests
tests.t1()
tests.t2()
collectgarbage()
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
