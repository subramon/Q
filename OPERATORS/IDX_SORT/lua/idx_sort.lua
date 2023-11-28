local Q       = require 'Q/q_export'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qc      = require 'Q/UTILS/lua/qcore'
local record_time      = require 'Q/UTILS/lua/record_time'

local function idx_sort(idx, val, ordr)
  local specializer = "Q/OPERATORS/IDX_SORT/lua/idx_sort_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(idx, val, ordr))
  assert(type(subs) == "table")
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  local t_start = cutils.rdtsc()
  -- create new vectors with old vector's data but in lma format
  local outidx = idx:chunks_to_lma()
  local outval = val:chunks_to_lma()

  -- Now, get access to idx data 
  local idx_cmem, _, idx_len = outidx:get_lma_write()
  assert(type(idx_cmem) == "CMEM")
  assert(idx_cmem:is_foreign() == true)
  local idx_ptr = get_ptr(idx_cmem, subs.cast_idx_as)

  -- Now, get access to val data 
  local val_cmem, _, val_len = outval:get_lma_write()
  assert(type(val_cmem) == "CMEM")
  assert(val_cmem:is_foreign() == true)
  local val_ptr = get_ptr(val_cmem, subs.cast_val_as)

  -- do the real work 
  qc[func_name](idx_ptr, val_ptr, idx_len)
  -- Indicate write is over 
  outidx:unget_lma_write()
  outval:unget_lma_write()
  record_time(t_start, "sort1")
  return outidx, outval 

end
return require('Q/q_export').export('idx_sort', idx_sort)
