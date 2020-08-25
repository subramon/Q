local cmem = require 'libcmem' ;
local qc = require 'Q/UTILS/lua/qcore'
local utils = require 'Q/UTILS/lua/utils'

local tests = {}
local niter = 100000000

tests.t1 = function()
  -- basic test 
  local start_time = qc.RDTSC()
  for i = 1, niter do 
    local buf = cmem.new(1048576, "I4", "hello world")
    assert(type(buf) == "CMEM")
    if ( ( i % 1000000 ) == 0 ) then 
      print(i) 
      y = cmem:print_mem(true)
    end 
  end
  collectgarbage()
  local y = cmem:print_mem(true)
  assert(y == 0)
  local stop_time = qc.RDTSC()
  print("stress_test_cmem t1 time(seconds): ", utils["RDTSC"](stop_time-start_time))
  print("Test RUNTIME/test/stress_test_cmem.lua t1 succeeded")
end

tests.t2 = function()
  -- basic test
  local start_time = qc.RDTSC()
  local X = {}
  local niter = 1048576
  local buf
  for i = 1, niter do 
    buf = cmem.new(i, "I4", "string_" .. i)
    assert(type(buf) == "CMEM")
    if ( ( i % 65536 ) == 0 ) then 
      print(i) 
      y = cmem:print_mem(true)
    end 
    buf:delete()
  end
  local stop_time = qc.RDTSC()
  print("stress_test_cmem t2 time(seconds): ", utils["RDTSC"](stop_time-start_time))
  print("Test RUNTIME/test/stress_test_cmem.lua t2 succeeded")
end

  
return tests
