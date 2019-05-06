return function(f1_qtype, f2_qtype, ordr)
  local qconsts = require 'Q/UTILS/lua/q_consts'
  assert(type(ordr) == "string", "sort order should be a string")
  assert( ( ( ordr == "asc") or ( ordr == "dsc") ),
  "Sort order should be asc or dsc")
  local subs = {}
  local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/SORT2/lua/sort2.tmpl"
  subs.SORT_ORDER = ordr
  subs.F1_QTYPE = f1_qtype
  subs.F2_QTYPE = f2_qtype
  subs.fn = "sort2_" .. ordr .. "_" .. f1_qtype .. "_" .. f2_qtype
  subs.F1_FLDTYPE = qconsts.qtypes[f1_qtype].ctype
  subs.F2_FLDTYPE = qconsts.qtypes[f2_qtype].ctype
  subs.in_qtype = f1_qtype
  -- TODO Check below is correct order/comparator combo
  local c = ""
  if ordr == "asc" then c = "<" end
  if ordr == "dsc" then c = ">" end
  subs.COMPARATOR = c
  return subs, tmpl
end
