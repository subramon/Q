local cutils = require 'libcutils'

return function(invec, sort_order)

  assert(type(invec) == "lVector")
  assert(invec:is_eov())
  assert(not invec:has_nulls())

  assert(type(sort_order) == "string", "Sort order should be a string")
  if ( sort_order == "ascending"  ) then sort_order = "asc" end
  if ( sort_order == "descending" ) then sort_order = "dsc" end
  assert( ( ( sort_order == "asc") or ( sort_order == "dsc") ))
  --========================================
  local subs = {}
  subs.F_IN_PLACE_ORDER = sort_order
  local in_qtype = invec:qtype()
  subs.qtype = in_qtype
  subs.fn = "qsort_" .. sort_order .. "_" .. in_qtype
  subs.FLDTYPE = cutils.str_qtype_to_str_ctype(in_qtype)
  subs.cast_y_as = subs.FLDTYPE .. " *"
  -- TODO Check below is correct order/comparator combo
  if sort_order == "asc" then subs.COMPARATOR = "<" end
  if sort_order == "dsc" then subs.COMPARATOR = ">" end
  subs.tmpl   = "OPERATORS/SORT1/lua/qsort.tmpl"
  subs.incdir = "OPERATORS/SORT1/gen_inc/"
  subs.srcdir = "OPERATORS/SORT1/gen_src/"
  subs.incs = { "OPERATORS/SORT1/gen_inc/" }
  subs.sort_order = sort_order
  return subs
end
