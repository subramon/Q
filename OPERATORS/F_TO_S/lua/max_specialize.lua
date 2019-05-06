local qconsts = require 'Q/UTILS/lua/q_consts'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

return function (qtype)
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/lua/reduce.tmpl"
  local subs = {}
  if ( qtype == "B1" ) then
    assert(nil, "TODO")
    subs.reduce_qtype = "I1"
  else
    assert(is_base_qtype(qtype), "qtype must be base type")
    subs.op = "max"
    subs.fn = subs.op .. "_" .. qtype 
    subs.ctype = qconsts.qtypes[qtype].ctype
    subs.qtype = qtype
    subs.reduce_ctype = subs.ctype
    subs.reduce_qtype = qtype
    if ( qtype == "I1" ) then subs.initial_val = "INT8_MIN" end
    if ( qtype == "I2" ) then subs.initial_val = "INT16_MIN" end
    if ( qtype == "I4" ) then subs.initial_val = "INT32_MIN" end
    if ( qtype == "I8" ) then subs.initial_val = "INT64_MIN" end
    -- Updated the initial val for F4 and F8
    -- FLT_MIN and DBL_MIN have minimum, normalized, positive value of float and double
    -- so for negative values in input vector, these are not appropriate initial values
    if ( qtype == "F4" ) then subs.initial_val = "-FLT_MAX-1" end
    if ( qtype == "F8" ) then subs.initial_val = "-DBL_MAX-1" end
    assert(subs.initial_val)
    subs.reducer = "mcr_max"
    subs.t_reducer = subs.reducer
    --==============================
  end
  return subs, tmpl
end
