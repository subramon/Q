return function (
  a_qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
  local subs = {}; local tmpl
  assert(is_base_qtype(a_qtype), "type of A must be base type")
  subs.fn = "where_" .. a_qtype
  tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/WHERE/lua/where.tmpl"
  subs.a_ctype = qconsts.qtypes[a_qtype].ctype
  return subs, tmpl
end
