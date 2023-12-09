local T = {}
local function permute_to(x, y, optargs)
  local exp_file = 'Q/OPERATORS/PERMUTE/lua/expander_permute_to'
  local expander = assert(require(exp_file))
  local status, w = pcall(expander, x, y, optargs)
  if ( not status ) then print(w) return nil end 
  return w
end
T.permute_to = permute_to
require('Q/q_export').export('permute_to', permute_to)
--===============================================
return T
