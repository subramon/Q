require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local Scalar = require 'libsclr'
local cVector = require 'libvctr'
local orders = require 'Q/OPERATORS/F_IN_PLACE/lua/orders'
local qtypes = require 'Q/OPERATORS/F_IN_PLACE/lua/qtypes'
local lgutils = require 'liblgutils'
local tests = {}
tests.test_permute_from = function()
  local max_num_in_chunk = 64
  local len = max_num_in_chunk + 17

  local xargs = {
  len = len,
  start = 1, 
  by = 1,
  max_num_in_chunk = max_num_in_chunk
}
  local x2args = {
  len = len,
  start = len, 
  by = -1,
  max_num_in_chunk = max_num_in_chunk
}
  local pargs = {
  len = len,
  start = len-1, 
  by = -1,
  max_num_in_chunk = max_num_in_chunk
}
  local p2args = {
  len = len,
  start = len-1, 
  by = -1,
  max_num_in_chunk = max_num_in_chunk
}

local yargs = { num_elements = len, max_num_in_chunk = max_num_in_chunk}
local zargs = yargs
local val_qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
local prm_qtypes = { "I1", "I2", "I4", "I8", }
local val_qtypes = { "I4" } 
local prm_qtypes = { "I4" } 
  for _, val_qtype in ipairs(val_qtypes) do
    for _, prm_qtype in ipairs(prm_qtypes) do
      xargs.qtype = val_qtype 
      local x = Q.seq(xargs):set_name("x")

      pargs.qtype = prm_qtype 
      local p = Q.seq(pargs):set_name("p")

      x2args.qtype = val_qtype 
      local x2 = Q.seq(x2args):set_name("x")

      p2args.qtype = prm_qtype 
      local p2 = Q.seq(p2args):set_name("p2")

      local xprime = x:eval():chunks_to_lma()
      local y = Q.permute_from(xprime, p):set_name("y")
      assert(type(y) == "lVector")
      assert(y:qtype() == x:qtype())
      assert(not y:is_eov())
      y:eval()
      x:pr("_x")
      p:pr("_p")
      y:pr("_y")

--[[
      local y2 = Q.permute_from(x, p2, yargs):set_name("y")
      assert(type(y2) == "lVector")
      assert(y2:is_eov())
      y2 = y2:lma_to_chunks()
      local z = Q.permute_from(y, p, zargs):set_name("z")
      assert(z:is_eov())
      z = z:lma_to_chunks()
      local n1, n2 = Q.sum(Q.vveq(x, z)):eval()
      assert(n1 == n2)
      local n1, n2 = Q.sum(Q.vveq(x, y)):eval()
      assert(n1 == n2)
      -- check other permutataion p2 
      local n1, n2 = Q.sum(Q.vveq(x2, y2)):eval()
      assert(n1 == n2)

      --]]
      assert(x:check())
      assert(p:check())
      assert(x2:check())
      assert(p2:check())
      assert(y:check())
      assert(xprime:check())
      assert(cVector.check_all())

      assert(x:delete())
      assert(p:delete())
      assert(x2:delete())
      assert(p2:delete())
      assert(y:delete())
      assert(xprime:delete())

      assert(cVector.check_all())
      print("Successfully completed test test_permute_from for ", val_qtype, prm_qtype)
      -- TODO Did a manual check but need to make a proper check for this 
    end
  end
  assert(cVector.check_all())
  print("Successfully completed test test_permute_from")
end
tests.test_permute_from()
collectgarbage()
print("MEM", lgutils.mem_used())
print("DSK", lgutils.dsk_used())
assert((lgutils.mem_used() == 0) and (lgutils.dsk_used() == 0))
-- return tests
