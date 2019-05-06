local qconsts = require 'Q/UTILS/lua/q_consts'
return function (
  in1_qtype
  )
  local promote = require 'Q/UTILS/lua/promote'
  local tmpl = 'lr_util.tmpl'
  local subs = {}; 
  subs.fn = "lr_util_" .. in1_qtype
  subs.in1_ctype = qconsts.qtypes[in1_qtype].ctype
  subs.out1_qtype = in1_qtype
  subs.out2_qtype = in1_qtype
  subs.out1_ctype = qconsts.qtypes[subs.out1_qtype].ctype
  subs.out2_ctype = qconsts.qtypes[subs.out2_qtype].ctype
  return subs, tmpl
end
