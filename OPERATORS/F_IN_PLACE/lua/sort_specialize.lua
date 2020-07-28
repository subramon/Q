local qconsts = require 'Q/UTILS/lua/q_consts'

return function(invec, ordr)

  assert(type(invec) == "lVector")
  assert(invec:is_eov())
  assert(not invec:has_nulls())

  assert(type(ordr) == "string", "Sort order should be a string")
  if ( ordr == "ascending"  ) then ordr = "asc" end
  if ( ordr == "descending" ) then ordr = "dsc" end
  assert( ( ( ordr == "asc") or ( ordr == "dsc") ))
  local subs = {}
  subs.F_IN_PLACE_ORDER = ordr
  local in_qtype = invec:qtype()
  subs.QTYPE = in_qtype
  subs.fn = "qsort_" .. ordr .. "_" .. in_qtype
  subs.FLDTYPE = qconsts.qtypes[in_qtype].ctype
  subs.cst_x_as = subs.FLDTYPE .. " *"
  -- TODO Check below is correct order/comparator combo
  if ordr == "asc" then subs.COMPARATOR = "<" end
  if ordr == "dsc" then subs.COMPARATOR = ">" end
  subs.tmpl   = "OPERATORS/F_IN_PLACE/lua/qsort.tmpl"
  subs.incdir = "OPERATORS/F_IN_PLACE/gen_inc/"
  subs.srcdir = "OPERATORS/F_IN_PLACE/gen_src/"
  subs.incs = { "OPERATORS/F_IN_PLACE/gen_inc/" }
  subs.ordr = ordr
  return subs
end
