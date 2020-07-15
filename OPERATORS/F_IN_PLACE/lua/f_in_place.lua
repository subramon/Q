local T = {} 
local function sort(x, y)
  local exp_file = 'Q/OPERATORS/F_IN_PLACE/lua/expander_f_in_place'
  local expander = assert(require(exp_file))
  local z = assert(expander("sort", x, y))
  return z
end
T.sort = sort
require('Q/q_export').export('sort', sort)
--===============================================
return T
