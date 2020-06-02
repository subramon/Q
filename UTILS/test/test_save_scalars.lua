local Q = require 'Q'
local Scalar = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local tests = {}

local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
local values = {127, 32767, 2147483647, 2147483650, 100.45, 1000.45}

-- scalar testcase for I1 qtype
for i, qtype in pairs(qtypes) do 
  local testname = "test_sclr_" .. qtype
  print(testname)
  tests[testname] = function()
    s1 = Scalar.new(values[i], qtype) -- creating global scalar
    assert(type(s1) == "Scalar")
    Q.save("/tmp/saving_sclrs.lua")
    s2 = s1
    s1 = nil -- nullifying s1 before restoring
    local status, ret = pcall(Q.restore, "/tmp/saving_sclrs.lua")
    assert(status, ret)
    assert(s1 == s2)
    assert(s1:fldtype() == qtype)
    print("Successfully executed test " .. testname)
  end
end
return tests
-- tests.test_sclr_F4()
