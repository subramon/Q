local qconsts = require 'Q/UTILS/lua/q_consts'

return function (
  f1type, 
  f2type
  )
  local sz1 = assert(qconsts.qtypes[f1type].width)
  local sz2 = assert(qconsts.qtypes[f2type].width)
  local iorf1 = assert(qconsts.iorf[f1type])
  local iorf2 = assert(qconsts.iorf[f2type])
  assert(iorf1 == "fixed", "f1type must be integer. Is" .. f1type)
  assert(iorf2 == "fixed", "f2type must be integer. Is" .. f2type)
  local out_qtype = nil
  if ( sz1 < sz2 ) then 
    out_qtype = f1type
  else
    out_qtype = f2type
  end
  local subs = {}

  subs.fn = "vvrem_" .. f1type .. "_" .. f2type .. "_" .. out_qtype
  subs.in1_ctype = assert(qconsts.qtypes[f1type].ctype)
  subs.in2_ctype = assert(qconsts.qtypes[f2type].ctype)
  subs.out_qtype = out_qtype
  subs.out_ctype = assert(qconsts.qtypes[out_qtype].ctype)

  subs.c_code_for_operator = " c = a % b ;"
  subs.tmpl = "OPERATORS/F1F2OPF3/lua/f1f2opf3.tmpl"
  subs.srcdir = "OPERATORS/F1F2OPF3/gen_src/"
  subs.incdir = "OPERATORS/F1F2OPF3/gen_inc/"
  subs.incs = { "OPERATORS/F1F2OPF3/gen_inc/", "UTILS/inc/"}
  return subs
en 
