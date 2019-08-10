local qconsts = require 'Q/UTILS/lua/q_consts'
local utils = require 'Q/UTILS/lua/utils'
local in_qtypes = { 'I1', 'I2', 'I4', 'I8' }
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/GROUPBY/lua/numby.tmpl"

return function (
  in_qtype, 
  is_safe
  )
  assert(utils.table_find(in_qtypes, in_qtype))
  local subs = {};

  subs.in_qtype = in_qtype
  subs.in_ctype = assert(qconsts.qtypes[subs.in_qtype].ctype)

  subs.out_qtype = "I8"
  subs.out_ctype = assert(qconsts.qtypes[subs.out_qtype].ctype)

  subs.fn = "numby_" .. in_qtype 
  subs.checking_code = " /* No checks made on value */ "
  subs.bye = " "
  if ( is_safe ) then 
    subs.fn = subs.fn .. "_safe"
    subs.checking_code = ' if ( ( x < 0 ) || ( (uint32_t)x >= nZ ) ) { \n printf("hello world"); \n go_BYE(-1); }  '
    subs.bye = "BYE: "
  end
  subs.tmpl = tmpl
  return subs
end
