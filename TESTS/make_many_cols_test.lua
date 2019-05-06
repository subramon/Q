local Q = require 'Q'
require 'Q/UTILS/lua/strict'

local tests = {}
tests.t1 = function ()

for i = 1,10000 do
  local c1 = Q.rand({ lb = -1048576, ub = 1048576, seed = 1234, qtype = "F4", len = 65537 } )
  c1:eval()
end

end
--======================================
return tests
