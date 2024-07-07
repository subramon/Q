local cutils   = require 'libcutils'
local lgutils  = require 'liblgutils'
local lVector  = require 'Q/RUNTIME/VCTR/lua/lVector'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local qc       = require 'Q/UTILS/lua/qcore'
local record_time = require 'Q/UTILS/lua/record_time'

-- NOTE: currently we support only an ascending sort 
-- NOTE: Sort occurs in place. 

-- bin_cnt[i] is the number of elements in the ith bin
-- For example, let n0 = bin_cnt[0]
-- This means that {x[0] .. x[n0-1]} is smaller than any element
-- in {x[n0] .. }
-- In other words, x has been partially sorted i.e., sorted *across* bins
-- But we still need to sort *within* bins
local function expander_par_idx_sort(idx, x, bin_cnt, optargs)
  local specializer = "Q/OPERATORS/PAR_IDX_SORT/lua/par_idx_sort_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(idx, x, bin_cnt))
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  -- We need input vector to be fully materialized and prepped for lma
  assert(x:is_eov())
  x:chunks_to_lma()
  assert(x:is_lma()) 
  --=============================
  local t_start = cutils.rdtsc()
  --======================================
  -- get access to x's data 
  local xcmem, _, nx = x:get_lma_write()
  local xptr = get_ptr(xcmem, subs.cast_x_as)

  -- get access to idxx's data 
  local idxcmem, _, nidx = idx:get_lma_write()
  local idxptr = get_ptr(idxcmem, subs.cast_idx_as)

  assert(nx == nidx) 

  local t_start = cutils.rdtsc()
  local status = qc[func_name](idxptr, xptr, subs.off, subs.cnt, subs.nb)
  assert(status == 0)

  x:unget_lma_write() -- Indicate write is over 
  idx:unget_lma_write() -- Indicate write is over 
  subs.off_cmem:delete()
  subs.cnt_cmem:delete()
  x:set_meta("sort_order",  "asc") -- only asc is supported
  record_time(t_start, subs.fn)
  return idx, x
end
return expander_par_idx_sort
