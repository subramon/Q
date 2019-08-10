local qconsts = require 'Q/UTILS/lua/q_consts'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/INDEX/lua/indices.tmpl"
return function (
  a_qtype
  )
  local subs = {}
  assert((a_qtype) == "B1", "type of A must be B1 type")
  subs.fn = "indices"
  -- subs.qtype = "B1"
  subs.a_ctype = qconsts.qtypes[a_qtype].ctype
  subs.tmpl = tmpl
  return subs
end
