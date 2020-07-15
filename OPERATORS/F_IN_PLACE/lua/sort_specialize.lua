local qconsts = require 'Q/UTILS/lua/q_consts'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'

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
  -- TODO Check below is correct order/comparator combo
  local c 
  if ordr == "asc" then c = "<" end
  if ordr == "dsc" then c = ">" end
  subs.COMPARATOR = c
  subs.tmpl   = "OPERATORS/F_IN_PLACE/lua/qsort.tmpl"
  subs.incdir = "OPERATORS/F_IN_PLACE/gen_inc/"
  subs.srcdir = "OPERATORS/F_IN_PLACE/gen_src/"
  subs.incs = { "OPERATORS/F_IN_PLACE/gen_inc/" }
  subs.ordr = ordr
  return subs
end
