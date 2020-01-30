local minmax_specialize = require 'Q/OPERATORS/F_TO_S/lua/minmax_specialize'
local function max_specialize(qtype)
  return minmax_specialize(qtype, "max")
end
return max_specialize
