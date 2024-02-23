local cutils   = require 'libcutils'
local lgutils  = require 'liblgutils'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
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
local function expander_par_sort(x, bin_cnt, optargs)
  local specializer = "Q/OPERATORS/PAR_SORT/lua/par_sort_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(x, bin_cnt))
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  -- We need input vector to be fully materialized and prepped for lma
  assert(x:is_eov())
  print("TODO JUST FOR TESTINGG") -- DELETE P0
  local dummy = cutils.exec("ls")
  assert(#dummy > 0)
  x:chunks_to_lma()
  assert(x:is_lma()) 
  print("TODO JUST FOR TESTINGG") -- DELETE P0
  dummy = cutils.exec("ls")
  assert(#dummy > 0)
  --=============================
  local t_start = cutils.rdtsc()
  --======================================
  -- Now, get access to x's data and perform the operation
  local xcmem, _, nx = x:get_lma_write()
  local xptr = get_ptr(xcmem, subs.cast_x_as)

  local t_start = cutils.rdtsc()
  local status = qc[func_name](xptr, subs.off, subs.cnt, subs.nb)
  assert(status == 0)

  x:unget_lma_write() -- Indicate write is over 
  subs.off_cmem:delete()
  subs.cnt_cmem:delete()
  x:set_meta("sort_order",  "asc") -- only asc is supported
  record_time(t_start, subs.fn)
  return x
end
return expander_par_sort
