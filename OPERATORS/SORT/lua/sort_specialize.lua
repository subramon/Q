return function(in_qtype, ordr)
  local qconsts = require 'Q/UTILS/lua/q_consts'
  assert(type(ordr) == "string", "Sort order should be a string")
  assert( ( ( ordr == "asc") or ( ordr == "dsc") ), 
  "Sort order should be asc or dsc")
  local subs = {}
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/SORT/lua/qsort.tmpl"
  subs.SORT_ORDER = ordr
  subs.QTYPE = in_qtype
  subs.fn = "qsort_" .. ordr .. "_" .. in_qtype
  subs.FLDTYPE = qconsts.qtypes[in_qtype].ctype
  -- TODO Check below is correct order/comparator combo
  local c = ""
  if ordr == "asc" then c = "<" end
  if ordr == "dsc" then c = ">" end
  subs.COMPARATOR = c
  return subs, tmpl
end
