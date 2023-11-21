local cutils = require 'libcutils'

return function(
    src_pk, src_t_start, src_t_stop,
    dst_pk, dst_t_start, dst_t_stop, dst_val, optargs)

  assert(type(src_pk) == "lVector")
  assert(type(src_pk) == "lVector")
  assert(type(src_t_start) == "lVector")
  assert(type(src_t_stop) == "lVector")
  assert(src_t_start:qtype() == src_t_stop:qtype())
  --==================================================
  assert(type(dst_pk) == "lVector")
  assert(type(dst_pk) == "lVector")
  assert(type(dst_t_start) == "lVector")
  assert(type(dst_t_stop) == "lVector")
  assert(dst_t_start:qtype() == dst_t_stop:qtype())
  --==================================================
  assert(src_t_start:qtype() == dst_t_start:qtype())
  assert(src_pk:qtype() == dst_pk:qtype())
  --==================================================
  assert(dst_pk:is_eov())
  assert(dst_t_start:is_eov())
  assert(dst_t_stop:is_eov())
  assert(dst_val:is_eov())

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
