local T = {}
local function unique(x, optargs)
  local expander = require 'Q/OPERATORS/UNIQUE/lua/expander_unique'
  local status, col1, col2 = pcall(expander, "unique", x, optargs)
  if not status then print(col1) end
  assert(status, "Could not execute UNIQUE")
  return col1, col2
end
T.unique = unique
require('Q/q_export').export('unique', unique)

return T
