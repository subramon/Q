-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local Scalar = require 'libsclr'

local qtypes = { "I1", "I2", "I4", "I8", }
local tests = {}
tests.t1 = function()
  for _, v_qtype in ipairs(qtypes) do 
    local c1 = Q.mk_col( {0, 1,2,3,4,5,6,7,}, v_qtype)
    local n = c1:num_elements()

    local c2 = Q.vsor(c1, Scalar.new(7, v_qtype))
    local r = Q.max(c2)
    local n1, n2 = r:eval()
    assert(n1:to_num() == 7)
    -- try again with zero mask 
    local c2 = Q.vsor(c1, Scalar.new(0, v_qtype)):eval()
    local x = Q.vconvert(Q.vveq(c1, c2), "I1")
    assert(type(x) == "lVector")
    local r = Q.sum(x)
    local n1, n2 = r:eval()
    assert(n1:to_num() == c2:num_elements())
    -- try again with larger mask 
    local c2 = Q.vsor(c1, Scalar.new(15, v_qtype)):eval()
    local r = Q.max(c2)
    local n1, n2 = r:eval()
    assert(n1:to_num() == 15)
  end
  print("test t1 passed")
end
-- return tests
tests.t1()
