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

tests.t1 = function()
  local num_trials = 100000
  local start_time = qc.RDTSC()
  for i = 1, num_trials do 
    -- create a nascent vector many times
    local y = Vector.new('I4', qconsts.Q_DATA_DIR)
    assert(y:check())
    local num_elements = 100000
    for j = 1, num_elements do 
      local s1 = Scalar.new(j, "I4")
      y:put1(s1)
      assert(y:check())
    end
    y:eov()
    assert(y:check())
    if ( ( i % 10 ) == 0 ) then print("Iter ", i)  end
  end
  local stop_time = qc.RDTSC()
  print("stress_test_vec time(seconds): ", utils["RDTSC"](stop_time-start_time))
  print("Successfully completed stress test: RUNTIME/test/stress_test_vec.lua")
end

return tests
