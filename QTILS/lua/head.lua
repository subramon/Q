local pr = require 'Q/OPERATORS/PRINT/lua/print_csv'
local T = {}
local function head(x, n)
  n = n or 10
  assert(x and type(x) == "lVector", "input must be of type lVector")
  assert( (type(n) == "number") and (n > 0 ) ) 
  x:eval()
  pr(x,  { filter = { lb = 0, ub = n} })
end
T.head = head
require('Q/q_export').export('head', head)
return T
