local utils = require 'Q/UTILS/lua/utils'
local val_qtypes = { 'I1', 'I2', 'I4', 'I8', 'F4', 'F8' }
local grpby_qtypes = { 'I1', 'I2', 'I4', 'I8' }
local qconsts = require 'Q/UTILS/lua/q_consts'
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/GROUPBY/lua/sumby.tmpl"

return function (
  val_qtype, 
  grpby_qtype,
  c -- condition field 
  )
  assert(utils.table_find(val_qtypes, val_qtype))
  assert(utils.table_find(grpby_qtypes, grpby_qtype))
  local out_qtype
  if ( ( val_qtype == "F4" ) or ( val_qtype == "F8" ) ) then 
    out_qtype = "F8"
  else
    out_qtype = "I8"
  end
  local subs = {};
  subs.val_ctype = qconsts.qtypes[val_qtype].ctype
  subs.grpby_ctype = qconsts.qtypes[grpby_qtype].ctype
  subs.out_qtype = out_qtype
  if ( c ) then 
    subs.ifcond = " if ( get_bit_u64(cfld, i) == 1 ) {  "
    subs.ifcond = " if ( ( cfld_s & 0x1 ) == 1 ) {  "
    subs.endif = " } "
    subs.fn = "sumby_where_" .. val_qtype .. "_" .. grpby_qtype .. 
      "_" .. out_qtype
    subs.ifpreamble = [[
      uint64_t cfld_s = cfld[0];
      int ctr = 0;
      int xidx = 0;
    ]]
    subs.ifloop = [[
      cfld_s = cfld_s >> 1; 
      ctr++; 
      if ( ctr == 64 ) { cfld_s = cfld[++xidx]; ctr = 0; }
    ]]
       
  else
    subs.fn = "sumby_" .. val_qtype .. "_" .. grpby_qtype .. 
      "_" .. out_qtype
  end
  subs.out_ctype = qconsts.qtypes[out_qtype].ctype
  subs.tmpl = tmpl
  return subs
end
