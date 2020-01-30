local minmax_specialize = require 'Q/OPERATORS/F_TO_S/lua/minmax_specialize'
local function min_specialize(qtype)
  return minmax_specialize(qtype, "min")
end
return min_specialize
