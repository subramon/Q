local minmax_specialize = require 'Q/OPERATORS/F_TO_S/lua/minmax_specialize'
local function max_specialize(x, optargs)
  return minmax_specialize("max", x, optargs)
end
return max_specialize
