local Q = require 'Q'
local Scalar = require 'libsclr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local tests = {}

local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }

S1 = {}
tests.t1 = function()
  -- test restore of table of Scalars
  for i, qtype in pairs(qtypes) do 
    S1[#S1+1] = Scalar.new(1,  qtype) -- creating global scalar
  end
  Q.save("/tmp/saving_sclrs.lua")
  S2 = S1
  S1 = nil -- nullifying S1 before restoring
  local status, ret = pcall(Q.restore, "/tmp/saving_sclrs.lua")
  assert(status, ret)
  for i, s2 in pairs(S2) do
    assert(S1[i] == s2)
  end
  print("Successfully executed t1")
end
return tests
-- tests.t1()
