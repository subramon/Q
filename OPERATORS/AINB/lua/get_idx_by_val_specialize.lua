return function (
  idx_qtype,
  val_qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
  local subs = {}; local tmpl
  assert( (idx_qtype == "I1" ) or (idx_qtype == "I2" ) or 
          (idx_qtype == "I4" ) or (idx_qtype == "I8" ) )
  assert(is_base_qtype(val_qtype), "val_type must be base type")

  subs.fn = "bin_search_get_idx_" .. idx_qtype .. "_by_val_" .. val_qtype
  tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/AINB/lua/bin_search_get_idx_by_val.tmpl"
  subs.idx_qtype = idx_qtype
  subs.idx_ctype = qconsts.qtypes[idx_qtype].ctype

  subs.val_qtype = val_qtype
  subs.val_ctype = qconsts.qtypes[val_qtype].ctype
  return subs, tmpl
end
