local cmem = require 'libcmem' ;
local cutils = require 'libcutils'

local tests = {}
local niter = 100000000

tests.t1 = function()
  -- basic test 
  local start_time = cutils.rdtsc()
  for i = 1, niter do 
    local buf = cmem.new(
      {size = 1048576, qtype = "I4", name = "helloworld"})
    assert(type(buf) == "CMEM")
    if ( ( i % 1000000 ) == 0 ) then 
      print(i) 
    end 
  end
  collectgarbage()
  local stop_time = cutils.rdtsc()
  print("stress_test_cmem t1 time(seconds): ", (stop_time-start_time))
  print("Test RUNTIME/test/stress_test_cmem.lua t1 succeeded")
end
tests.t1()
  
-- return tests
