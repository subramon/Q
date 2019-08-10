local qconsts = require 'Q/UTILS/lua/q_consts'
local Scalar  = require 'libsclr'
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1OPF2F3/lua/split.tmpl"

return function (
  in_qtype
  )

  local out_qtype 
  local shift
  if ( in_qtype == "I8" ) then 
    out_qtype = "I4"
    shift = 32
  elseif ( in_qtype == "I4" ) then 
    out_qtype = "I2"
    shift = 16
  elseif ( in_qtype == "I2" ) then 
    out_qtype = "I1"
    shift = 8
  else
    assert(nil, "Bad in_qtype = " .. in_qtype)
  end

  local subs = {}; 
  subs.fn = "split_" .. in_qtype .. "_" .. out_qtype 
  subs.in_ctype  = qconsts.qtypes[in_qtype].ctype
  subs.out_qtype = out_qtype
  subs.out_ctype = qconsts.qtypes[out_qtype].ctype
  subs.shift     = shift
  subs.tmpl = tmpl
  return subs
end
