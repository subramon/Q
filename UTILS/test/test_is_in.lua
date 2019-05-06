-- FUNCTIONAL
require "Q/UTILS/lua/strict"
local Q = require 'Q'
local tests = {}
tests.t1 = function()
local is_in = require "Q/UTILS/lua/is_in"
local x = "number"
local X = { "number", "string", "table" }
local rslt = is_in(x, X)
assert(rslt == true)
x = "foobar"
local rslt = is_in(x, X)
assert(rslt == false)
print("Test t1 succeeded")
end
return tests
