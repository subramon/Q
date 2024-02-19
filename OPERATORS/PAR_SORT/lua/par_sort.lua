local T = {}
local function par_sort(x, y, optargs)
  local exp_file = 'Q/OPERATORS/PAR_SORT/lua/expander_par_sort'
  local expander = assert(require(exp_file))
  local z = assert(expander(x, y, optargs))
  return z
end
T.par_sort = par_sort
require('Q/q_export').export('par_sort', par_sort)
--===============================================
return T
