local Q       = require 'Q/q_export'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qc      = require 'Q/UTILS/lua/qcore'
local record_time      = require 'Q/UTILS/lua/record_time'

local function idx_sort(idx, val, ordr, optargs)
  local specializer = "Q/OPERATORS/IDX_SORT/lua/idx_sort_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(idx, val, ordr))
  assert(type(subs) == "table")
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  local t_start = cutils.rdtsc()

  idx:chunks_to_lma(); val:chunks_to_lma()

  assert(idx:num_readers() == 0); assert(idx:num_writers() == 0)
  assert(val:num_readers() == 0); assert(val:num_writers() == 0)
  -- determine whether to sort in place
  local in_situ = false
  if ( optargs ) then
    assert(type(optargs) == "table")
    if ( optargs.in_situ ) then
      assert(type(optargs.in_situ) == "boolean")
      in_situ = optargs.in_situ
    end
  end
  local outidx, outval
  if ( in_situ ) then 
    outidx = idx
    outval = val
  else
    outidx = idx:clone()
    outval = val:clone()
  end 
  --=============================

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

  assert(outidx:num_readers() == 0); assert(outidx:num_writers() == 1)
  assert(outval:num_readers() == 0); assert(outval:num_writers() == 1)

  -- do the real work 
  qc[func_name](idx_ptr, val_ptr, idx_len)
  -- Indicate write is over 
  outidx:unget_lma_write()
  outval:unget_lma_write()
  record_time(t_start, "sort1")

  assert(outidx:num_readers() == 0); assert(outidx:num_writers() == 0)
  assert(outval:num_readers() == 0); assert(outval:num_writers() == 0)
  outval:set_meta("sort_order", ordr)

  return outidx, outval 

end
return require('Q/q_export').export('idx_sort', idx_sort)
