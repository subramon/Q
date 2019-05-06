
return function (
  val_qtype, 
  grpby_qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local utils = require 'Q/UTILS/lua/utils'
  local val_qtypes = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8' }
  local grpby_qtypes = { 'I1', 'I2', 'I4', 'I8' }
  assert(utils.table_find(val_qtypes, val_qtype))
  assert(utils.table_find(grpby_qtypes, grpby_qtype))
  local out_qtype
  if ( ( val_qtype == "F4" ) or ( val_qtype == "F8" ) ) then 
    out_qtype = "F8"
  else
    out_qtype = "I8"
  end
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/GROUPBY/lua/sumby_where.tmpl"
  local subs = {};
  subs.fn = "sumby_where_" .. val_qtype .. "_" .. grpby_qtype .. "_" .. out_qtype
  subs.val_ctype = qconsts.qtypes[val_qtype].ctype
  subs.grpby_ctype = qconsts.qtypes[grpby_qtype].ctype
  subs.out_qtype = out_qtype
  subs.out_ctype = qconsts.qtypes[out_qtype].ctype
  return subs, tmpl
end
