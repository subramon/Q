require 'Q/UTILS/lua/strict'
local Scalar = require 'libsclr' ; 

local tests = {}

tests.t1 = function ()
  -- y  = Scalar(123, "F4")
  local x  = Scalar.new(123, "F4")

  local a = Scalar.to_num(x)
  assert(a == 123)
  assert(tostring(x) == "123.000000")
  assert(Scalar.to_str(x) == "123.000000")
  --==================================
  local y  = Scalar.new("123", "I4")
  assert(x == y)
  assert(Scalar.eq(x, y))
  --==================================
  local w = Scalar.new("1234", "F4")
  assert(x ~= w)
  assert(Scalar.neq(x, w))
  assert(not Scalar.eq(x, w))
  --==================================
  assert(x < w)
  assert(x <= w)

  print("Successfully completed test t1")
end

-- return tests
tests.t1()
