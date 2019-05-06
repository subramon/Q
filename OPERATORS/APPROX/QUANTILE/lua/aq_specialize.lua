return function (
  qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  
  local is_base_qtype = assert(require 'Q/UTILS/lua/is_base_qtype')
  assert(is_base_qtype(qtype))

  --==============================
  local subs = {}
  local tmpl_path = qconsts.Q_SRC_ROOT .. "/OPERATORS/APPROX/QUANTILE/lua/"
  local tmpls = {
    tmpl_path .. 'approx_quantile.tmpl',
    tmpl_path .. 'New.tmpl',
    tmpl_path .. 'Output.tmpl',
    tmpl_path .. 'Collapse.tmpl'
  }

  subs.ctype = qconsts.qtypes[qtype].ctype
  subs.qtype = qtype
  --subs.fn = "approx_quantile_" .. qtype
  return subs, tmpls
end
