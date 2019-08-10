local qconsts = require 'Q/UTILS/lua/q_consts'
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/DROP_NULLS/lua/drop_nulls.tmpl"
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
return function(in_qtype)
  assert(is_base_qtype(in_qtype))
  local subs = {}
  subs.qtype = in_qtype
  subs.fn    = "drop_nulls_" .. in_qtype
  subs.ctype = qconsts.qtypes[in_qtype].ctype
  subs.tmpl = tmpl
  return subs
end
