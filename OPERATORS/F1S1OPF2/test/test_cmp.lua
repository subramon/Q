require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local Scalar = require 'libsclr'

local tests = {}
tests.t1 = function()
  local len = 255
  local start1 = -127; local by1 = 1
  local start2 =  127; local by2 = -1
  for _, qtype in ipairs({"I1", "I2", "I4", "I8", "F4", "F8" }) do 
    local c1 = Q.seq({start = start1, by = by1, len = len, qtype = qtype})
    --===============================================
    local c2 = Q.vseq(c1,-127)
    assert(type(c2) == "lVector")
    local n1, n2 = Q.sum(c2):eval()
    assert(n1:to_num() == 1)
    assert(n2:to_num() == len)
    --===============================================
    local c2 = Q.vsneq(c1,-127)
    assert(type(c2) == "lVector")
    local n1, n2 = Q.sum(c2):eval()
    assert(n1:to_num() == len-1)
    assert(n2:to_num() == len)
    --===============================================
    local c2 = Q.vsleq(c1, 0)
    assert(type(c2) == "lVector")
    local n1, n2 = Q.sum(c2):eval()
    assert(n1:to_num() == 128)
    assert(n2:to_num() == len)
    --===============================================
    local c2 = Q.vsgeq(c1, 0)
    assert(type(c2) == "lVector")
    local n1, n2 = Q.sum(c2):eval()
    assert(n1:to_num() == 128)
    assert(n2:to_num() == len)
    --===============================================
    local c2 = Q.vslt(c1, 0)
    assert(type(c2) == "lVector")
    local n1, n2 = Q.sum(c2):eval()
    assert(n1:to_num() == 127)
    assert(n2:to_num() == len)
    --===============================================
    local c2 = Q.vsgt(c1, 0)
    assert(type(c2) == "lVector")
    local n1, n2 = Q.sum(c2):eval()
    assert(n1:to_num() == 127)
    assert(n2:to_num() == len)
    --===============================================
  end
end
tests.t1()
-- return tests
