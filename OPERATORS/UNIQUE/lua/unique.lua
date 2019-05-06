local T = {}
local function unique(x, y, optargs)
  local expander = require 'Q/OPERATORS/UNIQUE/lua/expander_unique'
  assert(x, "no arg x to unique")
  assert(type(x) == "lVector", "x is not lVector")
  if y then
    assert(type(y) == "lVector", "y is not lVector")
    assert(y:qtype() == "B1", "y is not of type B1")
  end
  local status, col1, col2, col3 = pcall(expander, "unique", x, y, optargs)
  if not status then print(col1) end
  assert(status, "Could not execute UNIQUE")
  return col1, col2, col3
end
T.unique = unique
require('Q/q_export').export('unique', unique)

return T
