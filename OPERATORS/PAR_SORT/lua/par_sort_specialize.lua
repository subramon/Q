local cutils = require 'libcutils'

return function(invec, bin_cnt)
  local subs = {}

  assert(type(invec) == "lVector")
  assert(invec:is_eov())
  assert(invec:has_nulls() == false)

  assert(type(bin_cnt) == "lVector")
  assert(bin_cnt:is_eov())
  assert(bin_cnt:has_nulls() == false)
  assert(bin_cnt:qtype() == "I8")

  -- TODO P3 Should have prefix_sums as an operator in F1OPF2
  -- START: make offsets
  -- get access to cnt 
  assert((cnt:qtype() == "I8") or (cnt:qtype() == "UI8"))
  local cntcmem, nn_cntcmem, ncnt = cnt:get_lma_read()
  local cntptr = get_ptr(cntcmem, "UI8")
  -- ==================
  local nb = cnt:num_elements()
  local sz = ffi.sizeof("uint64_t") * nb
  subs.off_cmem = cmem.new({qtype = "UI8", size = sz})
  subs.off = get_ptr(subs.off_cmem, "UI8")
  subs.off[0] = 0
  for i = 1, nb-1 do 
    subs.off[i] = cntptr[i-1] + subs.off[i-1]
  end
  cnt:unget_lma_read()

  subs.cnt = cntptr
  subs.nb = nb

  subs.xqtype = invec:qtype()
  subs.xctype = cutils.str_qtype_to_str_ctype(in_qtype)
  subs.cast_x_as = subs.xctype .. " *"
  -- STOP : make offsets
  --========================================
  -- TODO P0 everything below is suspect
  --
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
