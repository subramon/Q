local T = {}
local function sort(x, y, z, optargs)
  local exp_file = 'Q/OPERATORS/SORT1/lua/expander_sort1'
  local expander = assert(require(exp_file))
  local status, w = pcall(expander, x, y, z , optargs)
  if ( not status ) then print(w) return nil end 
  return w
end
T.permute = permute
require('Q/q_export').export('permute', permute)
--===============================================
return T
