local minmax_specialize = require 'Q/OPERATORS/F_TO_S/lua/minmax_specialize'
local function min_specialize(x, optargs)
  return minmax_specialize("min", x, optargs)
end
return min_specialize
