-- FUNCTIONAL
local Q = require 'Q'
local Scalar = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
require('Q/UTILS/lua/cleanup')()
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function()
  local qtypes =  { "I4", "I8" }
  local shifts = { "0", "1", "2", "3", "4", "5", "6", "7"}
  local len = qconsts.chunk_size * 2 + 17
  for _, qtype in pairs(qtypes) do 
    for _, shift in pairs(shifts) do 
      local x = Q.rand( { lb = 1, ub = 32767, qtype = qtype, len = len })
      local y = Q.shift_left(x, Scalar.new(shift, qtype))
      local mul = math.pow(2, shift)
      local z = Q.vsmul(x, Scalar.new(mul, qtype))
      -- Q.print_csv({x,y,z})
      local n1, n2 = Q.sum(Q.vveq(y, z)):eval()
      assert(n1 == n2)
    end
  end
  print("Test t1 succeeded")
end
tests.t2 = function()
  local qtypes =  { "I4", "I8" }
  local shifts = { "0", "1", "2", "3", "4", "5", "6", "7"}
  local len = qconsts.chunk_size * 2 + 17
  for _, qtype in pairs(qtypes) do 
    for _, shift in pairs(shifts) do 
      local x = Q.rand( { lb = 1, ub = 32767, qtype = qtype, len = len })
      local y = Q.shift_left(x, Scalar.new(shift, qtype))
      local z = Q.shift_right(x, Scalar.new(shift, qtype))
      -- Q.print_csv({x,y,z})
      local n1, n2 = Q.sum(Q.vveq(y, z)):eval()
      assert(n1 == n2)
    end
  end
  print("Test t2 succeeded")
end
tests.t3 = function()
  local qtype = "I4"
  local len = qconsts.chunk_size * 2 + 17
  local val = 19
  local shift = 7
  local x = Q.rand( { lb = 1, ub = 32767, qtype = qtype, len = len })
  local y1 = Q.shift_left(x, Scalar.new(shift, qtype))
  local y2 = Q.vsor(y1, Scalar.new(val, qtype))

  local mul = math.pow(2, shift)
  local z1 = Q.vsmul(x, Scalar.new(mul, qtype))
  local z2 = Q.vsadd(z1, Scalar.new(val, qtype))

  local n1, n2 = Q.sum(Q.vveq(y2, z2)):eval()
  assert(n1 == n2)
  print("Test t3 succeeded")
end
tests.t4 = function()
  local qtype = "I4"
  local len = qconsts.chunk_size * 2 + 17
  local val = 19
  local shift = 7
  local x = Q.rand( { lb = 1, ub = 32767, qtype = qtype, len = len })
  local y = Q.vsor(x, Scalar.new(32767, qtype))
  local z = Q.const({ val = 32767, qtype = qtype, len = len} )

  local n1, n2 = Q.sum(Q.vveq(y, z)):eval()
  assert(n1 == n2)
  print("Test t4 succeeded")
end
tests.t5 = function()
  local qtype = "I4"
  local len = qconsts.chunk_size * 2 + 17
  local val = 19
  local shift = 7
  local ub = 32767 * 32767
  local x = Q.rand( { lb = 1, ub = ub, qtype = qtype, len = len })
  local y = Q.vsand(x, Scalar.new(32767, qtype))
  local z = Q.const({ val = 32767, qtype = qtype, len = len} )

  local n1, n2 = Q.sum(Q.vvleq(y, z)):eval()
  assert(n1 == n2)
  print("Test t5 succeeded")
end
return tests

