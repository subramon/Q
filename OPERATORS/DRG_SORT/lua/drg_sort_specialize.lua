local is_in = require 'Q/UTILS/lua/is_in'
local cutils = require 'libcutils'
local good_drg_types = { "I1", "I2", "I4", "I8", "I16",
  "UI1", "UI2", "UI4", "UI8", "UI16", }
local good_val_types = { "I1", "I2", "I4", "I8", "I16",
  "UI1", "UI2", "UI4", "UI8",  "UI16", "F4", "F8", }

return function(drg, val, ordr)
  assert(type(ordr) == "string", "Sort ordr should be a string")
  if ( ordr == "ascending" )  then ordr = "asc" end 
  if ( ordr == "descending" ) then ordr = "dsc" end 
  assert(( ( ordr == "asc") or ( ordr == "dsc") ))
  --======================
  assert(type(drg) == "lVector")
  assert(is_in(drg:qtype(), good_drg_types))
  assert(drg:memo_len() < 0) -- cannot memo, need full Vector 
  drg:eval() -- force an eval 
  assert(drg:is_eov())
  assert(drg:has_nulls() == false)
  --======================
  assert(type(val) == "lVector")
  assert(is_in(val:qtype(), good_val_types))
  assert(val:memo_len() < 0) -- cannot memo, need full Vector 
  val:eval() -- force an eval 
  assert(val:is_eov())
  assert(val:has_nulls() == false)
  --======================
  assert(drg:num_elements() == val:num_elements())

  local subs = {}
  subs.srt_ordr = ordr

  subs.drg_qtype = drg:qtype()
  subs.drg_ctype = cutils.str_qtype_to_str_ctype(subs.drg_qtype)
  subs.cast_drg_as  = subs.drg_ctype .. " *"

  subs.val_qtype = val:qtype()
  subs.val_ctype = cutils.str_qtype_to_str_ctype(subs.val_qtype)
  subs.cast_val_as  = subs.val_ctype .. " *"

  subs.fn = "qsort_" .. ordr .. 
    "_val_" .. subs.val_qtype .. 
    "_drg_" .. subs.drg_qtype
  -- TODO Check below is correct ordr/comparator combo
  local c = ""
  if ordr == "asc" then c = "<" end
  if ordr == "dsc" then c = ">" end
  subs.comparator = c
  subs.tmpl   = "OPERATORS/drg_SORT/lua/drg_qsort.tmpl"
  subs.incdir = "OPERATORS/drg_SORT/gen_inc/"
  subs.srcdir = "OPERATORS/drg_SORT/gen_src/"
  subs.incs = { "UTILS/inc/", "OPERATORS/drg_SORT/gen_inc/" }
  return subs
end
