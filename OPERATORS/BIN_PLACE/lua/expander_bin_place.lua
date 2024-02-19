local cutils   = require 'libcutils'
local lgutils  = require 'liblgutils'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local qc       = require 'Q/UTILS/lua/qcore'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_bin_place(x, lb, ub, cnt, optargs)
  local specializer = "Q/OPERATORS/BIN_PLACE/lua/bin_place_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(x, lb, ub, cnt, optargs))
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  y = x:clone()
  local nx = y:num_elements()
  --=============================
  local t_start = cutils.rdtsc()
  -- Now, get access to pointers 

  y:chunks_to_lma()
  local ycmem, _, ny = y:get_lma_write()
  local yptr = get_ptr(ycmem, subs.cast_in_as)
  assert(y:num_writers() == 1)

  local lb_cmem, _, _ = lb:get_lma_read()
  local lbptr = get_ptr(lb_cmem, subs.cast_lb_as)
  local nlb = lb:num_elements()

  local ub_cmem, _, _ = ub:get_lma_read()
  local ubptr = get_ptr(ub_cmem, subs.cast_ub_as)

  local cnt_cmem, _, _ = cnt:get_lma_read()
  local cntptr = get_ptr(cnt_cmem, subs.cast_cnt_as)

  local offptr = get_ptr(subs.off_cmem, subs.cast_off_as)  -- offsets 
  local lckptr = get_ptr(subs.lck_cmem, subs.cast_lck_as)  -- lock 
  -- notice difference: offset is writable and is cmem not vector
  -- notice difference: lock is writable and is cmem not vector

  local chunk_num = 0
  local t_start = cutils.rdtsc()
  while true do 
    local nx, xcmem, _ = x:get_chunk(chunk_num)
    local xptr = get_ptr(xcmem, subs.cast_in_as)
    qc[func_name](xptr, nx, lbptr, ubptr, lckptr, offptr, nlb, yptr)
    x:unget_chunk(chunk_num)
    chunk_num = chunk_num + 1 
    if ( nx < x:max_num_in_chunk() ) then break end 
  end
  -- Above is an unusual function: returns void instead of int status 

  y:unget_lma_write() -- Indicate write is over 
  lb:unget_lma_read() -- Indicate read is over 
  ub:unget_lma_read() -- Indicate read is over 
  cnt:unget_lma_read() -- Indicate read is over 
  assert(x:num_readers() == 0)
  assert(y:num_writers() == 0)
  subs.off_cmem:delete()
  subs.lck_cmem:delete()
  record_time(t_start, subs.fn)
  return y
end
return expander_bin_place
