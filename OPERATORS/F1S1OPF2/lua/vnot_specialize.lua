local qconsts = require 'Q/UTILS/lua/q_consts'
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1S1OPF2/lua/vnot.tmpl"
return function (
  in_qtype
  )
  assert(in_qtype == "B1", "Only B1 is supported")
  --preamble
  local subs = {}; 
  subs.fn = "vnot_" .. in_qtype
  subs.in_ctype = qconsts.qtypes[in_qtype].ctype
  subs.in_qtype = in_qtype
  subs.out_qtype = in_qtype
  subs.out_ctype = qconsts.qtypes[subs.out_qtype].ctype
  subs.tmpl = tmpl
  return subs
end
