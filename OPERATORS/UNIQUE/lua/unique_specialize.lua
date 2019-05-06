return function (
  in_qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
  local subs = {}; local tmpl
  assert(is_base_qtype(in_qtype), "type of in must be base type")
  subs.fn = "unique" .. "_" .. in_qtype
  tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/UNIQUE/lua/unique.tmpl"
  subs.qtype = in_qtype
  subs.in_ctype = qconsts.qtypes[in_qtype].ctype
  return subs, tmpl
end
