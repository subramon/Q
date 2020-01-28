cutils = require 'libcutils'
local n = 1000000000
for i = 1, n do 
  local x = cutils.read("./stress_test.lua")
  assert(type(x) == "string")
  if ( ( i % 1000000 ) == 0 ) then 
    print("i/len = ", i, #x)
  end 
end
