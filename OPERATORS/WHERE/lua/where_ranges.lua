local T = {}
local function where_ranges(x, y, optargs)
  local expander = require 'Q/OPERATORS/where_ranges/lua/expander_where'
  local status, col = pcall(expander, x, y, optargs)
  if not status then print(col) end
  assert(status, "Could not execute where_ranges")
  return col
end
T.where_ranges = where
require('Q/q_export').export('where_ranges', where)

return T
