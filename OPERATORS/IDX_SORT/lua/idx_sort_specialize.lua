local is_in = require 'Q/UTILS/lua/is_in'
local cutils = require 'libcutils'
local good_idx_types = { "I1", "I2", "I4", "I8", 
  "UI1", "UI2", "UI4", "UI8",  }
local good_val_types = { "I1", "I2", "I4", "I8", 
  "UI1", "UI2", "UI4", "UI8",  "F4", "F8", }

return function(idx, val, ordr)
  assert(type(ordr) == "string", "Sort ordr should be a string")
  if ( ordr == "ascending" )  then ordr = "asc" end 
  if ( ordr == "descending" ) then ordr = "dsc" end 
  assert(( ( ordr == "asc") or ( ordr == "dsc") ))
  --======================
  assert(type(idx) == "lVector")
  assert(is_in(idx:qtype(), good_idx_types))
  assert(idx:is_eov())
  assert(idx:has_nulls() == false)
  --======================
  assert(type(val) == "lVector")
  assert(is_in(val:qtype(), good_val_types))
  assert(val:is_eov())
  assert(val:has_nulls() == false)
  --======================
  assert(idx:num_elements() == val:num_elements())

  local subs = {}
  subs.srt_ordr = ordr

  subs.idx_qtype = idx:qtype()
  subs.idx_ctype = cutils.str_qtype_to_str_ctype(subs.idx_qtype)
  subs.cast_idx_as  = subs.idx_ctype .. " *"

  subs.val_qtype = val:qtype()
  subs.val_ctype = cutils.str_qtype_to_str_ctype(subs.val_qtype)
  subs.cast_val_as  = subs.val_ctype .. " *"

  subs.fn = "qsort_" .. ordr .. 
    "_val_" .. subs.val_qtype .. 
    "_idx_" .. subs.idx_qtype
  -- TODO Check below is correct ordr/comparator combo
  local c = ""
  if ordr == "asc" then c = "<" end
  if ordr == "dsc" then c = ">" end
  subs.comparator = c
  subs.tmpl   = "OPERATORS/IDX_SORT/lua/idx_qsort.tmpl"
  subs.incdir = "OPERATORS/IDX_SORT/gen_inc/"
  subs.srcdir = "OPERATORS/IDX_SORT/gen_src/"
  subs.incs = { "UTILS/inc/", "OPERATORS/IDX_SORT/gen_inc/" }
  return subs
end
