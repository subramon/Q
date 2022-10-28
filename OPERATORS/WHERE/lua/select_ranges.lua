local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local T = {}
local function select_ranges(x, y, optargs)
  assert(type(x) == "lVector")
  assert(type(y) == "lVector")
  local expander = require 'Q/OPERATORS/WHERE/lua/expander_select_ranges'
  local status
  local col, nn_col
  status, col = pcall(expander, x, y, optargs)
  if not status then print(col) end
  assert(status, "Could not execute select_ranges()")
  return col
end
T.select_ranges = select_ranges
require('Q/q_export').export('select_ranges', select_ranges)

return T
