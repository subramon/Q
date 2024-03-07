local ffi      = require 'ffi'
local cutils   = require 'libcutils'
local lgutils  = require 'liblgutils'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local qc       = require 'Q/UTILS/lua/qcore'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_bin_place(x, aux, lb, ub, cnt, optargs)
  local specializer = "Q/OPERATORS/BIN_PLACE/lua/bin_place_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(x, aux, lb, ub, cnt, optargs))
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  local auxy = nil
  local auxycmem = nil
  local auxyptr = ffi.NULL
  local y = x:clone()
  if ( subs.has_aux ) then auxy = aux:clone() end
  --=============================
  local t_start = cutils.rdtsc()
  -- Now, get access to pointers 

  y:chunks_to_lma()
  local ycmem, _, ny = y:get_lma_write()
  local yptr = get_ptr(ycmem, subs.cast_in_as)
  assert(y:num_writers() == 1)

  if ( subs.has_aux ) then 
    auxy:chunks_to_lma()
    auxycmem, _, nauxy = auxy:get_lma_write()
    auxyptr = get_ptr(auxycmem, subs.cast_aux_as)
    assert(auxy:num_writers() == 1)
    assert(nauxy == ny)
  end 

  local lb_cmem, _, _ = lb:get_lma_read()
  local lbptr = get_ptr(lb_cmem, subs.cast_lb_as)
  local nlb = lb:num_elements()

  local ub_cmem, _, _ = ub:get_lma_read()
  local ubptr = get_ptr(ub_cmem, subs.cast_ub_as)

  local cnt_cmem, _, _ = cnt:get_lma_read()
  local cntptr = get_ptr(cnt_cmem, subs.cast_cnt_as)

  local offptr = get_ptr(subs.off_cmem, subs.cast_off_as)  -- offsets 

  local chunk_num = 0
  local t_start = cutils.rdtsc()
  while true do 
    local naux, auxxcmem
    local nx, xcmem, _ = x:get_chunk(chunk_num)
    local xptr = get_ptr(xcmem, subs.cast_in_as)
    local auxxptr = ffi.NULL
    if ( subs.has_aux ) then 
      naux, auxxcmem, _ = aux:get_chunk(chunk_num)
      auxxptr = get_ptr(auxxcmem, subs.cast_aux_as)
      assert(naux == nx) 
    end 
    local status = qc[func_name](xptr, nx, auxxptr, subs.aux_width,
      lbptr, ubptr, offptr, nlb, yptr, auxyptr)
    x:unget_chunk(chunk_num)
    if ( subs.has_aux ) then aux:unget_chunk(chunk_num) end 
    assert(status == 0)
    if ( subs.drop_mem ) then 
      x:drop_mem(1, chunk_num)
      aux:drop_mem(1, chunk_num)
    end 
    print("bin_place ", chunk_num)
    if ( nx < x:max_num_in_chunk() ) then break end 
    chunk_num = chunk_num + 1 
  end
  local t_stop = cutils.rdtsc()

  -- Indicate write is over 
  y:unget_lma_write() 
  if ( subs.has_aux ) then auxy:unget_lma_write() end
  -- Indicate read is over 
  lb:unget_lma_read() 
  ub:unget_lma_read() 
  cnt:unget_lma_read() 
  -- check all good 
  assert(x:num_readers() == 0)
  assert(y:num_writers() == 0)
  if ( subs.has_aux ) then assert(auxy:num_writers() == 0 ) end 
  subs.off_cmem:delete()
  record_time(t_start, subs.fn)
  return y, auxy
end
return expander_bin_place
