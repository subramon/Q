require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local Scalar = require 'libsclr'

local tests = {}
tests.t1 = function()
  local len = 127
  local start1 = -127; local by1 = 1
  local start2 =  127; local by2 = -1
  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8" }) do 
    local c1 = Q.seq({start = start1, by = by1, len = len, qtype = qtype})
    local n1, n2 = Q.sum(Q.vseq(c1,-127)):eval()
    assert(n1 == Scalar.new(1, "I4"))
  end
end
-- tests.t1()
return tests
