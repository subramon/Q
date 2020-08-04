local T = {} 
local function sort2(x, y, optargs)
  local exp_file = 'Q/OPERATORS/F1F2_IN_PLACE/lua/expander_f1f2_in_place'
  local expander = assert(require(exp_file))
  local z = assert(expander("sort2", x, y, optargs))
  return z
end
T.sort2 = sort2
require('Q/q_export').export('sort2', sort2)
--===============================================
return T
