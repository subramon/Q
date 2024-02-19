local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qc      = require 'Q/UTILS/lua/qcore'

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
  assert((bin_cnt:qtype() == "I8") or (bin_cnt:qtype() == "UI8"))
  bin_cnt:chunks_to_lma()
  local cntcmem, nn_cntcmem, ncnt = bin_cnt:get_lma_read()
  local cntptr = get_ptr(cntcmem, "UI8")
  -- ==================
  local nb = bin_cnt:num_elements()
  local sz = ffi.sizeof("uint64_t") * nb

  subs.cnt_cmem = cmem.new({qtype = "UI8", size = sz})
  subs.cnt = get_ptr(subs.cnt_cmem, "UI8")
  for i = 0, nb-1 do 
    subs.cnt[i] = cntptr[i] 
  end

  subs.off_cmem = cmem.new({qtype = "UI8", size = sz})
  subs.off = get_ptr(subs.off_cmem, "UI8")
  subs.off[0] = 0
  for i = 1, nb-1 do 
    subs.off[i] = cntptr[i-1] + subs.off[i-1]
  end
  assert(subs.off[nb-1] < invec:num_elements())
  bin_cnt:unget_lma_read()

  subs.nb = nb

  subs.xqtype = invec:qtype()
  subs.xctype = cutils.str_qtype_to_str_ctype(subs.xqtype)
  subs.cast_x_as = subs.xctype .. " *"
  -- STOP : make offsets
  --========================================
  -- START: Generate the sequential sort function that will be needed
  local xsubs = {}
  xsubs.F_IN_PLACE_ORDER = "asc"
  xsubs.xqtype = subs.xqtype
  xsubs.fn = "qsort_asc_" .. xsubs.xqtype
  xsubs.FLDTYPE = cutils.str_qtype_to_str_ctype(xsubs.xqtype)
  xsubs.cast_y_as = xsubs.FLDTYPE .. " *"
  xsubs.COMPARATOR = "<" 
  xsubs.tmpl   = "OPERATORS/SORT1/lua/qsort.tmpl"
  xsubs.incdir = "OPERATORS/SORT1/gen_inc/"
  xsubs.srcdir = "OPERATORS/SORT1/gen_src/"
  xsubs.incs = { "OPERATORS/SORT1/gen_inc/" }
  qc.q_add(xsubs)
  --========================================
  subs.fn = "par_qsort_" .. subs.xqtype
  subs.tmpl   = "OPERATORS/PAR_SORT/lua/par_sort.tmpl"
  subs.incdir = "OPERATORS/PAR_SORT/gen_inc/"
  subs.srcdir = "OPERATORS/PAR_SORT/gen_src/"
  subs.srcs = { "OPERATORS/SORT1/gen_src/" .. xsubs.fn .. ".c" }
  subs.incs = { "OPERATORS/PAR_SORT/gen_inc/", 
    "OPERATORS/SORT1/gen_inc/", "UTILS/inc/", }
  return subs
end
