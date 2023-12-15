local from_scalar = require 'Q/UTILS/lua/from_scalar'
local Scalar = require 'libsclr'
local tests = {}

tests.t1 = function()
  local x = Scalar.new("ABC", "SC")
  local y = from_scalar(x)
  assert(type(y) == "string")
  assert(y == "ABC")

  local x = Scalar.new(1234.5678)
  local y = from_scalar(x)
  assert(type(y) == "number")
  assert(y == 1234.5678)

  local x = Scalar.new(1234, "I4")
  local y = from_scalar(x)
  assert(type(y) == "number")
  assert(y == 1234)

  local x = Scalar.new(true, "BL")
  local y = from_scalar(x)
  assert(type(y) == "boolean")
  assert(y == true)

  local x = Scalar.new(false, "BL")
  local y = from_scalar(x)
  assert(type(y) == "boolean")
  assert(y == false)

  print("Successfully completed test t1 ")
end
-- return tests
tests.t1()
