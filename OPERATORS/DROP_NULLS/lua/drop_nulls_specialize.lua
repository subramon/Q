return function(in_qtype)
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
  assert(is_base_qtype(in_qtype))
  local subs = {}
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/DROP_NULLS/lua/drop_nulls.tmpl"
  subs.qtype = in_qtype
  subs.fn    = "drop_nulls_" .. in_qtype
  subs.ctype = qconsts.qtypes[in_qtype].ctype
  return subs, tmpl
end
