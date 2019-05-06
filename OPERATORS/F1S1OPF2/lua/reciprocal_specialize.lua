return function (
  in_qtype
  )
  local qconsts = require 'Q/UTILS/lua/q_consts'
  local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
  assert(is_base_qtype(in_qtype), "Valid only for base qtypes")
  --preamble
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1S1OPF2/lua/f1opf2.tmpl"
  local subs = {}; 
  subs.fn = "reciprocal_" .. in_qtype 
  subs.in_ctype = qconsts.qtypes[in_qtype].ctype
  subs.c_code_for_operator = "c = 1 / a; "
  subs.in_qtype = in_qtype
  subs.out_qtype = in_qtype
  subs.out_ctype = qconsts.qtypes[subs.out_qtype].ctype
  return subs, tmpl
end
