return function(in_qtype)
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local subs = {}
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/MDB/lua/mk_comp_key_val.tmpl.lua"
  subs.QTYPE = in_qtype
  subs.fn = "mk_comp_key_val_" .. in_qtype
  subs.VALTYPE = qconsts.qtypes[in_qtype].ctype
  return subs, tmpl
end
