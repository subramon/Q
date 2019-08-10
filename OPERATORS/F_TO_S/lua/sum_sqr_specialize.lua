local qconsts = require 'Q/UTILS/lua/q_consts'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/lua/sum.tmpl"

return function (qtype)
  local subs = {}
  assert(is_base_qtype(qtype), "qtype must be base type, not" .. qtype) 
  subs.op = "sum_sqr" 
  subs.macro = "mcr_sqr"
  subs.fn = subs.op .. "_" .. qtype 
  subs.ctype = qconsts.qtypes[qtype].ctype
  subs.qtype = qtype
  subs.initial_val = 0
  if ( ( qtype == "I1" ) or ( qtype == "I2" ) or 
       ( qtype == "I4" ) or ( qtype == "I8" ) ) then
    subs.reduce_ctype = "uint64_t" 
    subs.reduce_qtype = "I8" 
  elseif ( ( qtype == "F4" ) or ( qtype == "F8" ) ) then
    subs.reduce_ctype = "double"
    subs.reduce_qtype = "F8"
  else
    assert(nil, "Invalid qtype " .. qtype)
  end
  subs.reducer = "mcr_sqr"
  subs.t_reducer = "mcr_sum"
  subs.tmpl = tmpl
  --==============================
  return subs
end
