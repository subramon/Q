require 'Q/UTILS/lua/strict'
local Scalar = require 'libsclr' ; 

local tests = {}

tests.t1 = function ()
  local s8 = Scalar.new("9223372036854775807", "I8")
  local s1 = Scalar.new("-1", "I8")
  local s2 = Scalar.add(s8, s1)
  --========
  s2 = s8 + s1
  local y = s2:to_str("I8")
  assert(y == "9223372036854775806")
  --========
  s2 = s8 - Scalar.new("1", "I8")
  y = s2:to_str("I8")
  assert(y == "9223372036854775806")
  --========
  print("Successfully completed test t1")
end
--================
-- return tests
tests.t1()
