local T = {}
local function sort(x, y, optargs)
  local exp_file = 'Q/OPERATORS/SORT1/lua/expander_sort1'
  local expander = assert(require(exp_file))
  local z = assert(expander(x, y, optargs))
  return z
end
T.sort = sort
require('Q/q_export').export('sort', sort)
--===============================================
return T
