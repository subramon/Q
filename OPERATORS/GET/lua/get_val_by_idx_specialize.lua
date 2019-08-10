local to_scalar = require 'Q/UTILS/lua/to_scalar'
local qconsts = require 'Q/UTILS/lua/q_consts'
local Scalar  = require 'libsclr'
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/GET/lua/get_val_by_idx.tmpl"

return function (
  in1_qtype, 
  in2_qtype,
  optargs
  )

  local out_qtype = in2_qtype
  local sclr_null_val
  if ( optargs ) then 
    assert(type(optargs) == "table")
    local null_val = optargs.null_val
    if ( not null_val ) then 
      sclr_null_val = Scalar.new(0, in2_qtype)
    else
      sclr_null_val = to_scalar(null_val, in2_qtype)
    end
  else
    sclr_null_val = Scalar.new(0, in2_qtype)
  end 
  assert( ( in1_qtype == "I1" ) or 
  ( in1_qtype == "I2" ) or 
  ( in1_qtype == "I4" ) or 
  ( in1_qtype == "I8" ) )

  local subs = {}
  subs.fn = "get_val_" .. in2_qtype .. "_by_idx_" .. in1_qtype 
  subs.in1_ctype = qconsts.qtypes[in1_qtype].ctype
  subs.in2_ctype = qconsts.qtypes[in2_qtype].ctype
  subs.out_qtype = out_qtype
  subs.null_val = sclr_null_val
  subs.out_ctype = qconsts.qtypes[out_qtype].ctype
  subs.tmpl = tmpl
  return subs
end
