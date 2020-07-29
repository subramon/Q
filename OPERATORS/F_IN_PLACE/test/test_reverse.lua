-- FUNCTIONAL require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local Scalar = require 'libsclr'
local qtypes = require 'Q/OPERATORS/F_IN_PLACE/lua/qtypes'
local tests = {}
local len  = 127
tests.t1 = function()
  for _, qtype in ipairs(qtypes) do
    local x = Q.seq({ qtype = qtype, start = 1, by = 1, len = len}):eval()
    x:set_name("x")
    x:master()
    local xprime = x:clone():set_name("xprime")
    assert(type(xprime) == "lVector")
    xprime:master()
    local y = Q.reverse(xprime)
    local n1, n2 = Q.sum(Q.vveq(x, xprime)):eval()
    assert(n1 == Scalar.new(1))

    local z = Q.reverse(y)
    local n1, n2 = Q.sum(Q.vveq(x, z)):eval()
    assert(n1 == n2)
  end
  print("Successfully completed test t1")
end
-- tests.t1()
-- os.exit()
return tests
