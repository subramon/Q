--FUNCTIONAL
local Q = require 'Q'
require 'Q/UTILS/lua/strict'
local timer = require 'posix.time'

local tests = {}

tests.t1 = function()
  --local a = Q.seq( {start = 10, by = 10, qtype = "I4", len = 10} )
  local num_elements = 10000000
  local col1 = {}
  for i=1, num_elements do
    col1[#col1 +1] = i
  end	
  local start_time_1 = timer.clock_gettime(0)
  local a = Q.mk_col(col1, "I4")
  local b = Q.mk_col(col1, "I4")
  local stop_time_1 = timer.clock_gettime(0)
  local time_1 =  (stop_time_1.tv_sec*10^6 +stop_time_1.tv_nsec/10^3 - (start_time_1.tv_sec*10^6 +start_time_1.tv_nsec/10^3))/10^6
  print("Mk_col: ", time_1)
  
  local start_time_2 = timer.clock_gettime(0)
  local add = Q.vvadd(a,b)
  add:eval()
  local stop_time_2 = timer.clock_gettime(0)
  local time_2 =  (stop_time_2.tv_sec*10^6 +stop_time_2.tv_nsec/10^3 - (start_time_2.tv_sec*10^6 +start_time_2.tv_nsec/10^3))/10^6
  print("vvadd: ", time_2)
  print("Num_elements:", add:length())
  --local add = Q.vvadd(a,b)
  print("Test t1 succeeded")
end
return tests
