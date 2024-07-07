cutils = require 'libcutils'
local n = 1000000000
for i = 1, n do 
  -- local x = cutils.read("./stress_test.lua")
  local x = cutils.dirname("/home/subramon/stress_test.lua")
  local y = cutils.basename("/home/subramon/stress_test.lua")
  assert(type(x) == "string")
  assert(type(y) == "string")
  if ( ( i % 10000000 ) == 0 ) then 
    print("i/len = ", i, #x)
  end 
end
