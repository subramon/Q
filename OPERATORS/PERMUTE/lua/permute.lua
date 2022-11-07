local T = {}
local function permute(x, y, z, optargs)
  local exp_file = 'Q/OPERATORS/PERMUTE/lua/expander_permute'
  local expander = assert(require(exp_file))
  local status, w = pcall(expander, x, y, z , optargs)
  if ( not status ) then print(w) return nil end 
  return w
end
T.permute = permute
require('Q/q_export').export('permute', permute)
--===============================================
return T
