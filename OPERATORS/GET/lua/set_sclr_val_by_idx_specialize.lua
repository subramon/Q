local to_scalar = require 'Q/UTILS/lua/to_scalar'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Scalar  = require 'libsclr'

return function (
  idx_qtype, 
  val_qtype,
  optargs
  )

  local out_qtype = val_qtype
  local sclr_val
  assert(optargs)
  assert(type(optargs) == "table")
  sclr_val = assert(optargs.sclr_val)
  sclr_val = to_scalar(sclr_val, val_qtype)
  assert( 
    ( idx_qtype == "I1" ) or ( idx_qtype == "I2" ) or 
    ( idx_qtype == "I4" ) or ( idx_qtype == "I8" ) )

  local subs = {}
  local tmpl
  tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/GET/lua/set_sclr_val_by_idx.tmpl"
  subs.fn = "set_sclr_val_" .. val_qtype .. "_by_idx_" .. idx_qtype 

  subs.idx_ctype = qconsts.qtypes[idx_qtype].ctype
  subs.val_ctype = qconsts.qtypes[val_qtype].ctype

  subs.sclr_val = sclr_val
  return subs, tmpl
end
