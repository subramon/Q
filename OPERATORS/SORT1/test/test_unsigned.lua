require 'Q/UTILS/lua/strict'
local Q       = require 'Q'
local Scalar  = require 'libsclr'
local orders  = require 'Q/OPERATORS/F_IN_PLACE/lua/orders'
local qtypes  = require 'Q/OPERATORS/F_IN_PLACE/lua/qtypes'
local cVector = require 'libvctr'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local lgutils = require 'liblgutils'
local tests = {}
tests.t1 = function()
  local x = Q.mk_col({-4, -3, -2, -1, 0, 1, 2, 3, 4, }, "I4")
  assert(cVector.check_all())
  x = x:cast("UI4")
  assert(x:qtype() == "UI4")
  local y1 = Q.sort(x, "dsc")
  x = y1:cast("I4")
  assert(y1:qtype() == "I4")
  y1:pr()
  print("Successfully completed test t1")
end
tests.t1()
collectgarbage()
-- print("MEM", lgutils.mem_used())
-- print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
