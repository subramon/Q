local qconsts = require 'Q/UTILS/lua/q_consts'
return function(f1, f2, optargs)
  assert(type(f1) == "lVector", "error")
  assert(type(f2) == "lVector", "error")
  -- Check the vector x for eval(), if not then call eval()
  assert(f1:is_eov())
  assert(f2:is_eov())
  assert(not f1:has_nulls())
  assert(not f2:has_nulls())
  local f1_qtype = f1:qtype()
  local f2_qtype = f2:qtype()
  f1:master() -- TODO P3 Delete later
  f2:master() -- TODO P3 Delete later
  -- Flush needed because start_write assumes file exists

  local ordr
  if ( type(optargs) == "string" ) then 
    ordr = optargs
  elseif ( type(optargs) == "table" ) then
    ordr = assert(optargs.ordr)
  else
    error("")
  end
  assert(type(ordr) == "string", "sort order should be a string")
  if ( ordr == "ascending" )  then ordr = "asc" end
  if ( ordr == "descending" ) then ordr = "dsc" end
  assert(( ( ordr == "asc") or ( ordr == "dsc") ))

  local subs = {}
  subs.SORT_ORDER = ordr
  subs.F1_QTYPE = f1_qtype
  subs.F2_QTYPE = f2_qtype
  subs.fn = "sort2_" .. ordr .. "_" .. f1_qtype .. "_" .. f2_qtype
  subs.F1_FLDTYPE = qconsts.qtypes[f1_qtype].ctype
  subs.F2_FLDTYPE = qconsts.qtypes[f2_qtype].ctype
  subs.in_qtype = f1_qtype
  -- TODO Check below is correct order/comparator combo
  local c
  if ordr == "asc" then c = "<" end
  if ordr == "dsc" then c = ">" end
  subs.COMPARATOR = c
  subs.tmpl   = "OPERATORS/F1F2_IN_PLACE/lua/sort2.tmpl"
  subs.srcdir = "OPERATORS/F1F2_IN_PLACE/gen_src/"
  subs.incdir = "OPERATORS/F1F2_IN_PLACE/gen_inc/"
  subs.incs = { "OPERATORS/F1F2_IN_PLACE/gen_inc/", "UTILS/inc" }
  return subs
end
