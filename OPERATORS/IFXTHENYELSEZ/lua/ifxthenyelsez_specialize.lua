return function (
  variation,
  qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
  local subs = {}; local tmpl
  local variations = { vv = true, vs = true, sv = true, ss = true }
  assert(variations[variation])
  assert(is_base_qtype(qtype))
  subs.fn = variation .. "_ifxthenyelsez_" .. qtype 
  tmpl = qconsts.Q_SRC_ROOT	 .. "/OPERATORS/IFXTHENYELSEZ/lua/" .. variation .. "_ifxthenyelsez.tmpl"
  subs.ctype = qconsts.qtypes[qtype].ctype
  subs.qtype = qtype
  return subs, tmpl
end
