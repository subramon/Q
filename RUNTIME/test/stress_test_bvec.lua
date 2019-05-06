local plpath = require 'pl.path'
local Vector = require 'libvec' ; 
local Scalar = require 'libsclr' ; 
local cmem = require 'libcmem' ;
local qconsts = require 'Q/UTILS/lua/q_consts'
local qc = require 'Q/UTILS/lua/q_core'
local utils = require 'Q/UTILS/lua/utils'
require 'Q/UTILS/lua/strict'

-- for k, v in pairs(vec) do print(k, v) end 
local tests = {} 
-- 
tests.t1 = function()
  local start_time = qc.RDTSC()
  local num_trials = 100000
  for i = 1, num_trials do 
    -- create a nascent vector a bit at a time
    local y = Vector.new('B1', qconsts.Q_DATA_DIR)
    assert(y:check())
    local num_elements = 100000
    for j = 1, num_elements do 
      local bval = nil
      if ( ( j % 2 ) == 0 ) then bval = true else bval = false end
      local s1 = Scalar.new(bval, "B1")
      y:put1(s1)
      assert(y:check())
    end
    y:eov()
    assert(y:check())
    print("Iter = ", i)
  end
  local stop_time = qc.RDTSC()
  print("stress_test_bvec time(seconds): ", utils["RDTSC"](stop_time-start_time))
  print("Successfully completed test RUNTIME/test/stress_test_bvec.lua")
end

return tests
