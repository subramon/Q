local T = {}
local function permute_from(x, y, optargs)
  local exp_file = 'Q/OPERATORS/PERMUTE/lua/expander_permute_from'
  local expander = assert(require(exp_file))
  local status, w = pcall(expander, x, y, optargs)
  if ( not status ) then print(w) return nil end 
  return w
end
T.permute_from = permute_from
require('Q/q_export').export('permute_from', permute_from)
--===============================================
return T
