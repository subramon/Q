local T = {}
local function where(x, y, optargs)
  local expander = require 'Q/OPERATORS/WHERE/lua/expander_where'
  assert(x, "no arg x to where")
  assert(y, "no arg y to where")
  assert(type(x) == "lVector",  "x is not lVector")
  assert(type(y) == "lVector",  "y is not lVector")
  assert(y:qtype() == "B1", "y is not B1")
  local status, col = pcall(expander, x, y, optargs)
  if not status then print(col) end
  assert(status, "Could not execute WHERE")
  return col
end
T.where = where
require('Q/q_export').export('where', where)

return T
