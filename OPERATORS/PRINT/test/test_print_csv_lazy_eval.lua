-- FUNCTIONAL
require 'Q/UTILS/lua/strict'
local Q = require 'Q' 

local tests = {}

-- testing lazy evaluation for print_csv operator
tests.t1 = function()
  local x_length = 10
  local expected = "10\n20\n30\n40\n50\n60\n70\n80\n90\n100\n"
  
  local x = Q.seq( {start = 10, by = 10, qtype = "I4", len = x_length} )
  local string = Q.print_csv(x, {opfile = ""})
  
  assert(string)
  assert(string == expected)
  print("Test t1 succeeded")
end

return tests
