local T = {}
local function sort(x, y, optargs)
  local exp_file = 'Q/OPERATORS/F_IN_PLACE/lua/expander_f_in_place'
  local expander = assert(require(exp_file))
  local z = assert(expander("sort", x, y, optargs))
  return z
end
T.sort = sort
require('Q/q_export').export('sort', sort)
--===============================================
local function reverse(x, optargs)
  local exp_file = 'Q/OPERATORS/F_IN_PLACE/lua/expander_f_in_place'
  local expander = assert(require(exp_file))
  local z = assert(expander("reverse", x, optargs))
  return z
end
T.reverse = reverse
require('Q/q_export').export('reverse', reverse)
--===============================================
return T
