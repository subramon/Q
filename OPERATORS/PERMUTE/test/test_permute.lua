require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local Scalar = require 'libsclr'
local cVector = require 'libvctr'
local orders = require 'Q/OPERATORS/F_IN_PLACE/lua/orders'
local qtypes = require 'Q/OPERATORS/F_IN_PLACE/lua/qtypes'
local lgutils = require 'liblgutils'
local tests = {}
tests.t1 = function()
  local max_num_in_chunk = 64
  local len = max_num_in_chunk + 17

  local vargs = {
  len = len,
  start = 1, 
  by = 1,
  max_num_in_chunk = max_num_in_chunk
}
  local pargs = {
  len = len,
  start = 0, 
  by = 1,
  max_num_in_chunk = max_num_in_chunk
}

local yargs = { num_elements = len, max_num_in_chunk = max_num_in_chunk}
local zargs = yargs
local val_qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
local prm_qtypes = { "I1", "I2", "I4", "I8", }
  for _, val_qtype in ipairs(val_qtypes) do
    for _, prm_qtype in ipairs(prm_qtypes) do
      vargs.qtype = val_qtype 
      pargs.qtype = prm_qtype 
      local x = Q.seq(vargs):set_name("x")
      local p = Q.seq(pargs):set_name("p")
      local y = Q.permute(x, p, "to", yargs):set_name("y")
      assert(type(y) == "lVector")
      assert(y:is_eov())
      y = y:lma_to_chunks()
      -- y:pr()
      local z = Q.permute(y, p, "to", zargs):set_name("z")
      assert(z:is_eov())
      z = z:lma_to_chunks()
      local n1, n2 = Q.sum(Q.vveq(x, z)):eval()
      assert(n1 == n2)
      local n1, n2 = Q.sum(Q.vveq(x, y)):eval()
      assert(n1 == n2)

      assert(x:check())
      assert(p:check())
      assert(y:check())
      assert(z:check())
      x:delete()
      p:delete()
      y:delete()
      z:delete()
      assert(cVector.check_all())
      print("Successfully completed test t1 for ", val_qtype, prm_qtype)
    end
  end
  assert(cVector.check_all())
  print("Successfully completed test t1")
end
tests.t1()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
