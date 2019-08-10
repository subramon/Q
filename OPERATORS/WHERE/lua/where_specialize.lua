local qconsts       = require 'Q/UTILS/lua/q_consts'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/WHERE/lua/where.tmpl"
return function (
  a_qtype
  )
  local subs = {}; 
  assert(is_base_qtype(a_qtype), "type of A must be base type")
  subs.fn = "where_" .. a_qtype
  subs.a_ctype = qconsts.qtypes[a_qtype].ctype
  subs.tmpl = tmpl
  return subs
end
