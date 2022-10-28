local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/IDX_SORT/lua/idx_qsort.tmpl"
local qconsts = require 'Q/UTILS/lua/qconsts'
return function(idx_qtype, val_qtype, ordr)
  assert(type(ordr) == "string", "Sort order should be a string")
  assert( ( ( ordr == "asc") or ( ordr == "dsc") ), 
  "Sort order should be asc or dsc")

  local good_idx_types = { I1 = true, I2 = true, I4 = true, I8 = true }
  assert(good_idx_types[idx_qtype])

  -- TODO Replace this with somethine else: assert(qconsts.base_types[val_qtype])

  local subs = {}
  subs.srt_ordr = ordr
  subs.val_qtype = val_qtype
  subs.idx_qtype = idx_qtype
  subs.fn = "qsort_" .. ordr .. "_val_" .. val_qtype .. "_idx_" .. idx_qtype
  subs.idx_ctype = qconsts.qtypes[idx_qtype].ctype
  subs.val_ctype = qconsts.qtypes[val_qtype].ctype
  -- TODO Check below is correct order/comparator combo
  local c = ""
  if ordr == "asc" then c = "<" end
  if ordr == "dsc" then c = ">" end
  subs.comparator = c
  subs.tmpl = tmpl
  return subs
end
