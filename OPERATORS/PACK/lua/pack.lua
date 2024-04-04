local T = {}
local function pack(x, y, optargs)
  local exp_file = 'Q/OPERATORS/PACK/lua/expander_pack'
  local expander = assert(require(exp_file))
  local z = assert(expander(x, y, optargs))
  return z
end
T.pack = pack
require('Q/q_export').export('pack', pack)
--===============================================
return T
