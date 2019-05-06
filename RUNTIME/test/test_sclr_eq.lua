local vec = require 'libvec' ; 
local cmem = require 'libcmem' ; 
local Scalar = require 'libsclr' ; 

local tests = {}

tests.t1 = function ()
  -- y  = Scalar(123, "F4")
  local x  = Scalar.new(123, "F4")

  local a = Scalar.to_num(x)
  assert(a == 123)
  print(Scalar.to_str(x))
  assert(tostring(x) == "1.230000e+02")
  assert(Scalar.to_str(x) == "1.230000e+02")
  -- x  = Scalar.new(123, "F4")
  local y  = Scalar.new("123", "I4")
  -- z  = Scalar.eq(x, y)
  z = (x == y)
  assert(z == true)
  local w  = (x == Scalar.new("1234", "F4"))
  -- w  = Scalar.eq(x,  Scalar.new("1234", "F4"))
  assert(w == false)

  w  = (x ~= Scalar.new("1234", "F4"))
  -- w  = Scalar.eq(x,  Scalar.new("1234", "F4"))
  assert(w == true)

  w  = (x >= Scalar.new("1234", "F4"))
  -- w  = Scalar.eq(x,  Scalar.new("1234", "F4"))
  assert(w == false)

  w  = (x <= Scalar.new("1234", "F4"))
  -- w  = Scalar.eq(x,  Scalar.new("1234", "F4"))
  assert(w == true)

  print("Successfully completed test t1")
end

return tests
