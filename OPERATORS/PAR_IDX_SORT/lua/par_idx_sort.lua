local T = {}
local function par_idx_sort(x, y, z, optargs)
  local exp_file = 'Q/OPERATORS/PAR_IDX_SORT/lua/expander_par_idx_sort'
  local expander = assert(require(exp_file))
  local a, b = assert(expander(x, y, z, optargs))
  return a, b
end
T.par_idx_sort = par_idx_sort
require('Q/q_export').export('par_idx_sort', par_idx_sort)
--===============================================
return T
