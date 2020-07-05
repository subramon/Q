local qconsts = require 'Q/UTILS/lua/q_consts'
return function(in_qtype, ordr)
  assert(type(ordr) == "string", "Sort order should be a string")
  if ( ordr == "ascending"  ) then ordr = "asc" end 
  if ( ordr == "descending" ) then ordr = "dsc" end 
  assert( ( ( ordr == "asc") or ( ordr == "dsc") ))
  local subs = {}
  subs.SORT_ORDER = ordr
  subs.QTYPE = in_qtype
  subs.fn = "qsort_" .. ordr .. "_" .. in_qtype
  subs.FLDTYPE = qconsts.qtypes[in_qtype].ctype
  -- TODO Check below is correct order/comparator combo
  local c 
  if ordr == "asc" then c = "<" end
  if ordr == "dsc" then c = ">" end
  subs.COMPARATOR = c
  subs.tmpl   = "OPERATORS/SORT/lua/qsort.tmpl"
  subs.incdir = "OPERATORS/SORT/gen_inc/"
  subs.srcdir = "OPERATORS/SORT/gen_src/"
  return subs
end
