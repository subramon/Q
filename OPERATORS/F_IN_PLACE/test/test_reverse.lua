-- FUNCTIONAL require 'Q/UTILS/lua/strict'
local Q      = require 'Q'
local Scalar = require 'libsclr'
local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" } 
local tests = {}
local max_num_in_chunk  = 64 
local len  = 2 * max_num_in_chunk + 3 
tests.t1 = function()
  for _, qtype in ipairs(qtypes) do
    local x = Q.seq({ qtype = qtype, start = 1, by = 1, len = len})
    x = x:set_name("x"):eval()
    local xprime = x:clone():set_name("xprime")
    assert(type(xprime) == "lVector")
    -- check that xprime and x are the same but with different uqid
    assert(x:uqid() ~= xprime:uqid())
    assert(x:num_elements() == xprime:num_elements())
    for i = 1, len do 
      assert(x:get1(i-1) == xprime:get1(i-1))
    end
    --=======================
    local y = Q.reverse(xprime, {name = "y"})
    assert(y:is_eov())
    local n1, n2 = Q.sum(Q.vveq(x, xprime)):eval()
    assert(n1:to_num() == 0)

    local z = Q.reverse(y, {name = "z"})
    assert(z:is_eov())
    local n1, n2 = Q.sum(Q.vveq(x, z)):eval()
    assert(n1 == n2)
  end
  print("Successfully completed test t1")
end
tests.t1()
-- os.exit()
-- return tests
