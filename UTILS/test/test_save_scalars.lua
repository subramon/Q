local Q = require 'Q'
local utils = require 'Q/UTILS/lua/utils'
local Scalar = require 'libsclr'

local tests = {}
local qconsts = require 'Q/UTILS/lua/q_consts'

local qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
local values = {127, 32767, 2147483647, 2147483650, 100.45, 1000.45}

-- scalar testcase for I1 qtype
for i = 1, #qtypes do
  tests["sclr_" .. qtypes[i]] = function()
    -- creating global scalar
    sclr = Scalar.new(values[i], qtypes[i])
    Q.save("/tmp/saving_sclrs.lua")
    
    -- nullifying sc before restoring
    sclr = nil
    
    local status, ret = pcall(Q.restore, "/tmp/saving_sclrs.lua")
    assert(status, ret)
    if qtypes[i] == "F4" then
      assert(utils.round_num(sclr:to_num(), 2) == values[i])
    else
      assert(sclr:to_num() == values[i])
    end
    assert(sclr:fldtype() == qtypes[i])
    print("Successfully executed test " .. "sclr_" .. qtypes[i])
  end
end

return tests

