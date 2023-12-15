local T = {}
local function find(x, y, optargs)
  local exp_file = 'Q/OPERATORS/FIND/lua/expander_find'
  local expander = assert(require(exp_file))
  local z = assert(expander(x, y, optargs))
  return z
end
T.find = find
require('Q/q_export').export('find', find)
--===============================================
return T
