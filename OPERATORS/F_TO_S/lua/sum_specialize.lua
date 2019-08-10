local qconsts = require 'Q/UTILS/lua/q_consts'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/lua/sum.tmpl"

return function (qtype)
  local subs = {}
  subs.macro = "mcr_nop"
  if ( qtype == "B1" ) then
    subs.fn = "sum_B1"
    subs.reduce_ctype = "uint64_t"
    subs.reduce_qtype = "I8"
    subs.qtype = qtype
    subs.doth = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/inc/sum_B1.h"
    subs.dotc = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/inc/sum_B1.c"
  else
    assert(is_base_qtype(qtype), "qtype must be base type")
    subs.op = "sum"
    subs.fn = subs.op .. "_" .. qtype 
    subs.ctype = qconsts.qtypes[qtype].ctype
    subs.qtype = qtype
    subs.initial_val = 0
    if ( ( subs.qtype == "I1" ) or ( subs.qtype == "I2" ) or 
      ( subs.qtype == "I4" ) or ( subs.qtype == "I8" ) ) then
      subs.reduce_ctype = "int64_t" 
      subs.reduce_qtype = "I8" 
    elseif ( ( subs.qtype == "F4" ) or ( subs.qtype == "F8" ) ) then
      subs.reduce_ctype = "double" 
      subs.reduce_qtype = "F8" 
    else
      assert(nil)
    end
    subs.reducer = "mcr_nop"
    subs.t_reducer = "mcr_sum"
    subs.tmpl = tmpl
  end
  return subs
end
