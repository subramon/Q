local cutils   = require 'libcutils'
local lgutils  = require 'liblgutils'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local qc       = require 'Q/UTILS/lua/qcore'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_sort1(x, sort_order, optargs)
  local specializer = "Q/OPERATORS/SORT1/lua/sort1_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(x, sort_order))
  assert(type(subs) == "table")
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  -- Check is already sorted correct way and don't repeat
  local curr_sort_order = x:get_meta("sort_order")
  if ( subs.sort_order == curr_sort_order ) then return x end 
  -- determine whether to sort in place
  local in_situ = false
  if ( optargs ) then
    assert(type(optargs) == "table")
    if ( optargs.in_situ ) then
      assert(type(optargs.in_situ) == "boolean")
      in_situ = optargs.in_situ
    end
  end
  x:chunks_to_lma()
  -- We need input vector to be fully materialized and prepped for lma
  assert(x:is_eov())
  assert(x:is_lma()) 
  if ( not in_situ ) then 
    local file_name, file_sz = x:file_info()
    local copy_file_name = file_name .. cutils.rdtsc()
    cutils.copy_file(file_name, copy_file_name)
  end 
  --=============================
  local t_start = cutils.rdtsc()

  --======================================
  -- Now, get access to y's data and perform the operation
  local ycmem, nn_ycmem, num_elements = x:get_lma_write()
  assert(type(ycmem) == "CMEM")
  assert(type(nn_ycmem) == "nil")
  assert(ycmem:is_foreign() == true)
  local yptr = get_ptr(ycmem, subs.cast_y_as)

  qc[func_name](yptr, num_elements)
  -- Above is an unusual function: returns void instead of int status 

  -- Indicate write is over 
  x:unget_lma_write()
  x:set_meta("sort_order",  subs.sort_order)
  -- assert(y:num_readers() == 0)
  record_time(t_start, "sort1")
  return x
end
return expander_sort1
