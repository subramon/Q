local Q       = require 'Q/q_export'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qc      = require 'Q/UTILS/lua/qcore'
local record_time      = require 'Q/UTILS/lua/record_time'

local function drg_sort(drg, val, ordr, optargs)
  local specializer = "Q/OPERATORS/drg_sort/lua/drg_sort_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(drg, val, ordr))
  assert(type(subs) == "table")
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  local t_start = cutils.rdtsc()

  drg:chunks_to_lma(); val:chunks_to_lma()

  assert(drg:num_readers() == 0); 
  assert(drg:num_writers() == 0)
  assert(val:num_readers() == 0); 
  assert(val:num_writers() == 0)
  -- determine whether to sort in place
  local in_situ = false
  if ( optargs ) then
    assert(type(optargs) == "table")
    if ( optargs.in_situ ) then
      assert(type(optargs.in_situ) == "boolean")
      in_situ = optargs.in_situ
    end
  end
  local out_drg, out_val
  if ( in_situ ) then 
    out_drg = drg
    out_val = val
  else
    out_drg = drg:clone()
    out_val = val:clone()
  end 
  --=============================

  -- Now, get access to drg data 
  local drg_cmem, _, drg_len = out_drg:get_lma_write()
  assert(type(drg_cmem) == "CMEM")
  assert(drg_cmem:is_foreign() == true)
  local drg_ptr = get_ptr(drg_cmem, subs.cast_drg_as)

  -- Now, get access to val data 
  local val_cmem, _, val_len = out_val:get_lma_write()
  assert(type(val_cmem) == "CMEM")
  assert(val_cmem:is_foreign() == true)
  local val_ptr = get_ptr(val_cmem, subs.cast_val_as)

  assert(out_drg:num_readers() == 0); 
  assert(out_drg:num_writers() == 1)
  assert(out_val:num_readers() == 0); 
  assert(out_val:num_writers() == 1)

  -- do the real work 
  qc[func_name](drg_ptr, val_ptr, drg_len)
  -- Indicate write is over 
  out_drg:unget_lma_write()
  out_val:unget_lma_write()
  record_time(t_start, "sort1")

  assert(out_drg:num_readers() == 0); 
  assert(out_drg:num_writers() == 0)
  assert(out_val:num_readers() == 0); 
  assert(out_val:num_writers() == 0)
  out_val:set_meta("sort_order", ordr)

  return out_drg, out_val 

end
return require('Q/q_export').export('drg_sort', drg_sort)
