local qconsts = require 'Q/UTILS/lua/q_consts'
local is_in   = require 'Q/UTILS/lua/is_in'
local ok_qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
return function (
  in_qtype
  )
  assert(is_in(in_qtype, ok_qtypes))
  --preamble -- DO NOT DELETE THIS LINE!! Needed in Makefile 
  local subs = {}; 
  subs.fn        = "incr_" .. in_qtype 
  subs.in_ctype  = qconsts.qtypes[in_qtype].ctype
  subs.in_qtype  = in_qtype
  subs.out_qtype = in_qtype
  subs.out_ctype = qconsts.qtypes[subs.out_qtype].ctype
  subs.tmpl      = "OPERATORS/F1S1OPF2/lua/f1opf2.tmpl"
  subs.srcdir    = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir    = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.c_code_for_operator = "c = a + 1;"
  return subs
end
