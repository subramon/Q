-- FUNCTIONAL
require "Q/UTILS/lua/strict"
local multiple8 = require "Q/UTILS/lua/multiple8"
local tests = {}
tests.t1 = function()
  for i = 1, 17 do
    local val = multiple8(i)
    if ( i <= 8 ) then assert(val == 8 ) 
    elseif ( i <= 16 ) then assert(val == 16 ) 
    elseif ( i <= 24 ) then assert(val == 24 ) 
    else assert(nil) end
  end
  print("SUCCESS for t1 ")
end
return tests
