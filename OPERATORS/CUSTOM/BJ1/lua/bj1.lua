local T = {}
local function custom1(
  dst_pk, dst_t_start, dst_t_stop,
  src_pk, src_t_start, src_t_stop, src_val, optargs)
  local exp_file = 'Q/OPERATORS/CUSTOM/BJ1/lua/expander_bj1'
  local expander = assert(require(exp_file))
  local z = assert(expander(
  dst_pk, dst_t_start, dst_t_stop,
  src_pk, src_t_start, src_t_stop, src_val, optargs))
  return z
end
T.bj1 = bj1
require('Q/q_export').export('bj1', bj1)
--===============================================
return T
