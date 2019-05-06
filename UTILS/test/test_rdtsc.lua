local qc      = require 'Q/UTILS/lua/q_core'
local utils   = require 'Q/UTILS/lua/utils'

-- testing get_time_usec C function call from lua
local tests = {}
tests.t1 = function()
  local count = 10
  local start_time = qc['get_time_usec']()
  for i=0,10000000 do  
    count = count + 10;
  end
  local end_time = qc['get_time_usec']()
  print("Total execution time", tonumber(end_time)-tonumber(start_time))
end

-- testing qc.RDTSC() to return cpu cycles
-- and then calling utils.RDTSC utility which returns cpu time
tests.t2 = function()
  local count = 10
  local start_val = qc.RDTSC()
  for i=0,10000000 do
    count = count + 10;
  end
  local end_val = qc.RDTSC()
  print("Total cpu cycles", tonumber(end_val)-tonumber(start_val))
  local rdtsc_time = utils.RDTSC(tonumber(end_val)-tonumber(start_val))
  print("Total time", rdtsc_time)
end

return tests
