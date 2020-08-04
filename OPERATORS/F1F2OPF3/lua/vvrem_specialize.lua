local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local qconsts = require 'Q/UTILS/lua/q_consts'

return function (
  f1, 
  f2
  )
  assert(type(f1) == "lVector")
  assert(type(f2) == "lVector")
  assert(not f1:has_nulls())
  assert(not f2:has_nulls())
  local f1_qtype = f1:qtype()
  local f2_qtype = f2:qtype()

  local sz1 = assert(qconsts.qtypes[f1_qtype].width)
  local sz2 = assert(qconsts.qtypes[f2_qtype].width)
  local iorf1 = assert(qconsts.iorf[f1_qtype])
  local iorf2 = assert(qconsts.iorf[f2_qtype])
  assert(iorf1 == "fixed", "f1_qtype must be integer. Is " .. f1_qtype)
  assert(iorf2 == "fixed", "f2_qtype must be integer. Is " .. f2_qtype)
  local f3_qtype = nil
  if ( sz1 < sz2 ) then 
    f3_qtype = f1_qtype
  else
    f3_qtype = f2_qtype
  end
  local subs = {}

  subs.fn = "vvrem_" .. f1_qtype .. "_" .. f2_qtype .. "_" .. f3_qtype
  subs.f1_ctype = assert(qconsts.qtypes[f1_qtype].ctype)
  subs.f2_ctype = assert(qconsts.qtypes[f2_qtype].ctype)
  subs.f3_qtype = f3_qtype
  subs.f3_ctype = assert(qconsts.qtypes[f3_qtype].ctype)

  subs.f1_cast_as = subs.f1_ctype .. "*"
  subs.f2_cast_as = subs.f2_ctype .. "*"
  subs.f3_cast_as = subs.f3_ctype .. "*"

  subs.c_code_for_operator = " c = a % b ;"
  subs.tmpl = "OPERATORS/F1F2OPF3/lua/f1f2opf3.tmpl"
  subs.srcdir = "OPERATORS/F1F2OPF3/gen_src/"
  subs.incdir = "OPERATORS/F1F2OPF3/gen_inc/"
  subs.incs = { "OPERATORS/F1F2OPF3/gen_inc/", "UTILS/inc/"}
  return subs
end
