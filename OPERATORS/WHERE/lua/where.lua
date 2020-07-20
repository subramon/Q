local T = {}
local function where(x, y, optargs)
  local expander = require 'Q/OPERATORS/WHERE/lua/expander_where'
  local status, col = pcall(expander, x, y, optargs)
  if not status then print(col) end
  assert(status, "Could not execute WHERE")
  return col
end
T.where = where
require('Q/q_export').export('where', where)

return T
