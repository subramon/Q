require 'Q/UTILS/lua/strict'
local cmem = require 'libcmem' ; 
local Scalar = require 'libsclr' ; 

local tests = {}

tests.t1 = function ()
  for i = 1,1000 do
    local x = Scalar.new(123, "F4")
    local y = Scalar.new(456, "F4")
    local z = Scalar.add(x, y)
    z = x + y
    local w = (z == Scalar.new(579, "F4"))
    assert(w == true)

    z = Scalar.sub(y, x)
    w = (z == Scalar.new(333, "F4"))
    assert(w == true)

    assert(Scalar.gt(z, Scalar.new(331)))
    assert(Scalar.lt(z, Scalar.new(334)))
    assert(Scalar.geq(z, Scalar.new(333)))
    assert(Scalar.leq(z, Scalar.new(333)))

    --[[ TODO P4 Would be nice if following syntax would work
    assert(z > 331)
    assert(z < 333)
    assert(z >= 331)
    assert(z <= 333)
    --]]

  end
  print("Successfully completed test t1")
end

-- return tests
tests.t1()
