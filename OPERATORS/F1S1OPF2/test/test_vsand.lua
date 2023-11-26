-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local Scalar = require 'libsclr'

local qtypes = { "I1", "I2", "I4", "I8", }
local tests = {}
tests.t1 = function()
  for _, v_qtype in ipairs(qtypes) do 
    local c1 = Q.mk_col( {1,2,3,4,5,6,7,8}, v_qtype)
    local c2 = Q.vsand(c1, Scalar.new(15, v_qtype)):eval()
    local x = Q.vvneq(c1, c2)
    local r = Q.sum(x)
    local n1, n2 = r:eval()
    assert(n1:to_num() == 0)
    -- try again with tighter mask 
    local c2 = Q.vsand(c1, Scalar.new(7, v_qtype)):eval()
    local x = Q.vvneq(c1, c2)
    local r = Q.sum(x)
    local n1, n2 = r:eval()
    assert(n1:to_num() == 1)
    -- try again with tighter mask 
    local c2 = Q.vsand(c1, Scalar.new(3, v_qtype)):eval()
    local x = Q.vvneq(c1, c2)
    local r = Q.sum(x)
    local n1, n2 = r:eval()
    assert(n1:to_num() == 5)
    -- try again with zero mask 
    local c2 = Q.vsand(c1, Scalar.new(0, v_qtype)):eval()
    local x = Q.vvneq(c1, c2)
    local r = Q.sum(x)
    local n1, n2 = r:eval()
    assert(n1:to_num() == c2:num_elements())
  end
  print("test t1 passed")
end
-- return tests
tests.t1()
