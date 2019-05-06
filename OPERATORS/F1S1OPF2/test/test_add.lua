-- FUNCTIONAL
local Q = require 'Q'
local Scalar = require 'libsclr'
require('Q/UTILS/lua/cleanup')()
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function()
  local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, "I4")
  local c2 = Q.vsadd(c1, Scalar.new(10, "I8"))
  local c3 = Q.mk_col( {11,12,13,14,15,16,17,18}, "I4")
  -- local opt_args = { opfile = "" }
  -- c2:eval(); Q.print_csv(c2, opt_args)
  local sum = Q.sum(Q.vveq(c2, c3)):eval():to_num()
  assert(sum == c1:length(), "Length Mismatch, Expected : " .. c1:length() .. ", Actual: " .. sum)
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
return tests
