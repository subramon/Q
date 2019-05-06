return function (
  a_qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
  local subs = {}; local tmpl
  assert((a_qtype) == "B1", "type of A must be B1 type")
  subs.fn = "indices"
  tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/INDEX/lua/indices.tmpl"
  -- subs.qtype = "B1"
  subs.a_ctype = qconsts.qtypes[a_qtype].ctype
  return subs, tmpl
end
