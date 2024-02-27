local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qc      = require 'Q/UTILS/lua/qcore'
local is_in   = require 'Q/UTILS/lua/is_in'

return function(idxvec, invec, bin_cnt)
  local subs = {}

  assert(type(idxvec) == "lVector")
  assert(idxvec:is_eov())
  assert(idxvec:has_nulls() == false)

  -- We need input vector to be fully materialized and prepped for lma
  assert(invec:is_eov())
  invec:chunks_to_lma()
  assert(invec:is_lma()) 

  assert(type(idxvec) == "lVector")
  assert(idxvec:is_eov())
  assert(idxvec:has_nulls() == false)
  assert(is_in(idxvec:qtype(),
    { "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", }))

  -- We need input vector to be fully materialized and prepped for lma
  assert(idxvec:is_eov())
  idxvec:chunks_to_lma()
  assert(idxvec:is_lma()) 

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

  subs.idxqtype = idxvec:qtype()
  subs.idxctype = cutils.str_qtype_to_str_ctype(subs.idxqtype)
  subs.cast_idx_as = subs.idxctype .. " *"
  -- STOP : make offsets
  --========================================
  -- START: Generate the sequential sort function that will be needed
  local xsubs = {}
  local ordr = "asc" -- only thing supported currently
  xsubs.srt_ordr = ordr

  xsubs.idx_qtype = idxvec:qtype()
  xsubs.idx_ctype = cutils.str_qtype_to_str_ctype(xsubs.idx_qtype)
  xsubs.cast_idx_as  = xsubs.idx_ctype .. " *"

  xsubs.val_qtype = invec:qtype()
  xsubs.val_ctype = cutils.str_qtype_to_str_ctype(xsubs.val_qtype)
  xsubs.cast_val_as  = xsubs.val_ctype .. " *"

  xsubs.fn = "qsort_" .. ordr .. 
    "_val_" .. xsubs.val_qtype .. 
    "_idx_" .. xsubs.idx_qtype
  -- TODO Check below is correct ordr/comparator combo
  local c = ""
  if ordr == "asc" then c = "<" end
  if ordr == "dsc" then c = ">" end
  xsubs.comparator = c
  xsubs.tmpl   = "OPERATORS/IDX_SORT/lua/idx_qsort.tmpl"
  xsubs.incdir = "OPERATORS/IDX_SORT/gen_inc/"
  xsubs.srcdir = "OPERATORS/IDX_SORT/gen_src/"
  xsubs.incs = { "OPERATORS/IDX_SORT/gen_inc/", "UTILS/inc/", }
  qc.q_add(xsubs)
  --========================================
  subs.fn = "par_idx_qsort_val_" .. subs.xqtype .. "_idx_" .. subs.idxqtype
  subs.tmpl   = "OPERATORS/PAR_IDX_SORT/lua/par_idx_sort.tmpl"
  subs.incdir = "OPERATORS/PAR_IDX_SORT/gen_inc/"
  subs.srcdir = "OPERATORS/PAR_IDX_SORT/gen_src/"
  subs.srcs = { "OPERATORS/IDX_SORT/gen_src/" .. xsubs.fn .. ".c" }
  subs.incs = { "OPERATORS/PAR_IDX_SORT/gen_inc/", 
    "OPERATORS/IDX_SORT/gen_inc/", "UTILS/inc/", }
  return subs
end
