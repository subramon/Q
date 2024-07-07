local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local T = {}
local function select_ranges(x, lb, ub, optargs)
  local expander = require 'Q/OPERATORS/WHERE/lua/expander_select_ranges'
  local status
  local status, col = pcall(expander, x, lb, ub, optargs)
  if not status then print(col) end
  assert(status, "Could not execute select_ranges()")
  return col
end
T.select_ranges = select_ranges
require('Q/q_export').export('select_ranges', select_ranges)
return T
