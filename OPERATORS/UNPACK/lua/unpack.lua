local T = {}
local function unpack(invec, out_qtypes, optargs)
  local exp_file = 'Q/OPERATORS/UNPACK/lua/expander_unpack'
  local expander = assert(require(exp_file))
  local z = assert(expander(invec, out_qtypes, optargs))
  return z
end
T.unpack = unpack
require('Q/q_export').export('unpack', unpack)
--===============================================
return T
