-- FUNCTIONAL
local Q = require 'Q'
local Scalar = require 'libsclr'
require('Q/UTILS/lua/cleanup')()
require 'Q/UTILS/lua/strict'

local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
local tests = {}
tests.t1 = function()
  for _, v_qtype in ipairs(qtypes) do 
    local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, v_qtype)
    for _, s_qtype in ipairs(qtypes) do 
      local c2 = Q.vsadd(c1, Scalar.new(10, s_qtype))
      local c3 = Q.mk_col( {11,12,13,14,15,16,17,18}, v_qtype)
      local n1, n2 = Q.sum(Q.vveq(c2, c3)):eval()
      -- Q.print_csv({c1,c2,c3})
      assert(n1 == n2)

      local c4 = Q.vssub(c3, Scalar.new(10, s_qtype))
      local n1, n2 = Q.sum(Q.vveq(c1, c4)):eval()
      assert(n1 == n2)

    end
  end
end
tests.t2 = function()
  local len = 1000000
  local qtypes = { "I4", "I8", "F4", "F8" } 
  for k, qtype in ipairs(qtypes) do 
    local s = Scalar.new(2, qtype)
    local c1 = Q.seq({start = 1, by = 1, len = len, qtype = qtype })
    local s1, s2 = Q.sum(Q.vveq(Q.vssub(Q.vsadd(c1, s), s), c1)):eval()
    assert(s1 == s2)
    local s1, s2 = Q.sum(Q.vveq(Q.vsdiv(Q.vsmul(c1, s), s), c1)):eval()
    assert(s1 == s2)
  end
  print("test t2 passed")
end
-- return tests
tests.t1()
-- tests.t2()
