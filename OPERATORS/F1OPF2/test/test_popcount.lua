require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local cutils = require 'libcutils'
local Scalar = require 'libsclr' 
local lgutils = require 'liblgutils'

local good = {}
good.I1 = Q.mk_col({ 8, 0, 1, 1, 2, 1, 2, 2,}, "I1")

good.I2  = Q.mk_col({16, 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3,}, "I1")

good.I4  = Q.mk_col({32, 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, }, "I1")

good.I8 = Q.mk_col({64, 0, 1, 1, 2, 1, 2, 2, 3, 1, 2, 2, 3, 2, 3, 3, 4, 1, 2, 2,
3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4, 4, 5, 1, 2, 2, 3, 2, 3, 3, 4, 2, 3, 3, 4, 3, 4,
4, 5, 2, 3, 3, 4, 3, 4, 4, 5, 3, 4, 4, 5, 4, 5, 5,}, "I1")
local tests = {}
local prep = {}
local function prep(qtype)
  local len = cutils.get_width_qtype(qtype) * 8
  local vals = {}
  local val = -1
  for i = 1, len do 
    vals[#vals+1] = val
    val = val + 1
  end
  local x = Q.mk_col(vals, qtype)
  return x 
end

tests.t1 = function()
  for _, qtype in ipairs({"I1", "I2", "I4", "I8", }) do 
    local x = prep(qtype)
    local y = Q.popcount(x):eval()
    local z = Q.vvneq(y, good[qtype])
    local w = Q.sum(z)
    local n1, n2 = w:eval()
    assert(n1 == Scalar.new(0))
    -- Q.print_csv({x, y})
    x:delete()
    y:delete()
    z:delete()
    w:delete()
  end
  for k, v in pairs(good) do 
    v:delete()
  end
  print("Test t1 succeeded")
end
tests.t1()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests 
