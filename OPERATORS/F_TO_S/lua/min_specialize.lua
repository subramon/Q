local qconsts = require 'Q/UTILS/lua/q_consts'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')

return function (qtype)
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/lua/reduce.tmpl"
  local subs = {}
  if ( qtype == "B1" ) then
    subs.reduce_qtype = "I1"
    assert(nil, "TODO")
  else
    assert(is_base_qtype(qtype), "qtype must be base type")
    subs.op = "min"
    subs.fn = subs.op .. "_" .. qtype 
    subs.ctype = qconsts.qtypes[qtype].ctype
    subs.qtype = qtype
    subs.reduce_ctype = subs.ctype
    subs.reduce_qtype = qtype
    subs.reducer_struct_type = "REDUCE_min_" .. qtype .. "_ARGS"

    if ( qtype == "I1" ) then subs.initial_val = "INT8_MAX" end
    if ( qtype == "I2" ) then subs.initial_val = "INT16_MAX" end
    if ( qtype == "I4" ) then subs.initial_val = "INT32_MAX" end
    if ( qtype == "I8" ) then subs.initial_val = "INT64_MAX" end
    if ( qtype == "F4" ) then subs.initial_val = "FLT_MAX" end
    if ( qtype == "F8" ) then subs.initial_val = "DBL_MAX" end
    assert(subs.initial_val)
    subs.reducer   = "mcr_min"
    subs.t_reducer = "mcr_min"
    --==============================
  end
  return subs, tmpl
end
