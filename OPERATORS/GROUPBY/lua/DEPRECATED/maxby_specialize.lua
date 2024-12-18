local utils = require 'Q/UTILS/lua/utils'
local val_qtypes = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8' }
local grpby_qtypes = { 'I1', 'I2', 'I4', 'I8' }
local qconsts = require 'Q/UTILS/lua/q_consts'

return function (
  val_qtype, 
  grpby_qtype
  )
  assert(utils.table_find(val_qtypes, val_qtype))
  assert(utils.table_find(grpby_qtypes, grpby_qtype))
  local subs = {};
  subs.fn = "maxby_" .. val_qtype .. "_" .. grpby_qtype .. "_" .. val_qtype
  subs.val_ctype = qconsts.qtypes[val_qtype].ctype
  subs.grpby_ctype = qconsts.qtypes[grpby_qtype].ctype
  subs.out_qtype = val_qtype
  subs.out_ctype = qconsts.qtypes[val_qtype].ctype
  subs.t_reducer = "mcr_max"
  if ( val_qtype == "I1" ) then subs.initial_val = qconsts.qtypes[val_qtype].min end
  if ( val_qtype == "I2" ) then subs.initial_val = qconsts.qtypes[val_qtype].min end
  if ( val_qtype == "I4" ) then subs.initial_val = qconsts.qtypes[val_qtype].min end
  if ( val_qtype == "I8" ) then subs.initial_val = qconsts.qtypes[val_qtype].min end
  if ( val_qtype == "F4" ) then subs.initial_val = qconsts.qtypes[val_qtype].min end
  if ( val_qtype == "F8" ) then subs.initial_val = qconsts.qtypes[val_qtype].min end
  subs.tmpl = "OPERATORS/GROUPBY/lua/maxby_minby.tmpl"
  subs.srcdir = "OPERATORS/GROUPBY/gen_src/"
  subs.incdir = "OPERATORS/GROUPBY/gen_inc/"
  return subs
end
