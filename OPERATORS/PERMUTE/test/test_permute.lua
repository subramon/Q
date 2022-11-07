require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local Scalar = require 'libsclr'
local orders = require 'Q/OPERATORS/F_IN_PLACE/lua/orders'
local qtypes = require 'Q/OPERATORS/F_IN_PLACE/lua/qtypes'
local tests = {}
tests.t1 = function()
  local max_num_in_chunk = 64
  local len = max_num_in_chunk * 2 + 1 

  local vargs = {
  len = len,
  start = 1, 
  by = 1,
  max_num_in_chunk = max_num_in_chunk
}
  local pargs = {
  len = len,
  start = 1, 
  by = 1,
  max_num_in_chunk = max_num_in_chunk
}

-- local val_qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
-- local prm_qtypes = { "I1", "I2", "I4", "I8", }
local val_qtypes = { "F4", }
local prm_qtypes = { "I2", }
  for _, val_qtype in ipairs(val_qtypes) do
    for _, prm_qtype in ipairs(prm_qtypes) do
      vargs.qtype = val_qtype 
      pargs.qtype = prm_qtype 
      local x = Q.seq(vargs)
      local p = Q.seq(pargs)
      local y = Q.permute(x, p, "to", { num_elements = len})
      assert(y:is_eov())
      y:pr()
      local z = Q.permute(y, p, "to")
      assert(z:is_eov())
      z:pr()
      --[[
      local n1, n2 = Q.vveq(x, z):sum():eval()
      assert(n1 == n2)
      local n1, n2 = Q.vveq(x, y):sum():eval()
      assert(n1:to_num() == 0)
      --]]
      print("Successfully completed test t1 for ", val_qtype, prm_qtype)
    end
  end
  print("Successfully completed test t1")
end
tests.t1()
-- return tests
