local T = {} 
local function sort(x, y)
  local expander = assert(require 'Q/OPERATORS/F_IN_PLACE/lua/expander_f_in+place')
  local z = assert(expander("sort", x, y))
  return z
end
T.sort = sort
require('Q/q_export').export('sort', sort)
--===============================================
return T
