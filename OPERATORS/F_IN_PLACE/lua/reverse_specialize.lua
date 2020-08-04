local qconsts = require 'Q/UTILS/lua/q_consts'

return function(invec)
  assert(type(invec) == "lVector")
  assert(invec:is_eov())
  assert(not invec:has_nulls())

  local subs = {}
  local qtype = invec:qtype()

  subs.fn = "reverse_" .. qtype
  subs.ctype = qconsts.qtypes[qtype].ctype
  subs.cst_x_as = subs.ctype .. " *"
  subs.tmpl   = "OPERATORS/F_IN_PLACE/lua/reverse.tmpl"
  subs.incdir = "OPERATORS/F_IN_PLACE/gen_inc/"
  subs.srcdir = "OPERATORS/F_IN_PLACE/gen_src/"
  subs.incs = { "OPERATORS/F_IN_PLACE/gen_inc/" }
  return subs
end
