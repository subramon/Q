-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Scalar = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Q = require 'Q'

local tests = {}

tests.t1 = function()
  -- testing print_csv for I8 min & max value
  local expected = "9223372036854775807\n-9223372036854775808\n"
  local s1 = Scalar.new("9223372036854775807", "I8")
  local s2 = Scalar.new("-9223372036854775808", "I8")
  local x = Q.mk_col({s1, s2}, "I8")

  local string = Q.print_csv(x, {opfile = ""})
  assert(string)
  assert(string == expected)
  print("Test t1 succeeded")
end


return tests

