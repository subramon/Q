local lVector     = require 'Q/RUNTIME/VCTRS/lua/lVector'
local ffi         = require 'ffi' 
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local qc          = require 'Q/UTILS/lua/qcore'
local cmem        = require 'libcmem'
local cutils      = require 'libcutils'
local record_time = require 'Q/UTILS/lua/record_time'

local function get_val_by_idx(val, idx, optargs)

  local sp_fn_name = "Q/OPERATORS/GET/lua/get_val_by_idx_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs = pcall(spfn, val, idx, optargs)
  if not status then print(subs) end
  assert(status, subs)
  qc.q_add(subs)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not available" .. func_name)
  --=====================================
  local l_chunk_num = 0
  local gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    local out_buf = cmem.new( 
      { size = subs.out_bufsz, qtype = subs.out_qtype})
    out_buf:zero()
    out_buf:stealable(true)
    local out_ptr = get_ptr(out_buf, subs.cast_out_as)
    local nn_out_buf; local nn_out_ptr = ffi.NULL
    if ( subs.out_has_nulls ) then 
      nn_out_buf = cmem.new( 
        { size = subs.nn_out_bufsz, qtype = subs.nn_out_qtype})
      nn_out_buf:zero()
      nn_out_buf:stealable(true)
      nn_out_ptr = get_ptr(nn_out_buf, subs.cast_nn_out_as)
    end

    local val_cmem, _, val_len   = val:get_lma_write()
    assert(type(val_cmem) == "CMEM")
    assert(val_len > 0)
    local val_ptr = get_ptr(val_cmem, subs.cast_val_as)

    local idx_len, idx_chunk, nn_idx_chunk = idx:get_chunk(chunk_num)
    local idx_ptr = get_ptr(idx_chunk, subs.cast_idx_as)
    if ( idx_len == 0 ) then
      out_buf:delete()
      if ( nn_out_buf ) then nn_out_buf:delete() end
      return 0
    end 
    local start_time = cutils.rdtsc()
    local status = qc[func_name](val_ptr, val_len, idx_ptr, idx_len, 
      out_ptr, nn_out_ptr) 
    idx:unget_chunk(chunk_num)
    val:unget_lma_write()
    assert(status == 0)
    record_time(start_time, func_name)
    l_chunk_num = l_chunk_num + 1 
    return idx_len, out_buf, nn_out_buf
  end
  local vargs = {}
  vargs.gen = gen 
  vargs.qtype = subs.out_qtype
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  vargs.has_nulls = subs.out_has_nulls
  return lVector(vargs)
end

return require('Q/q_export').export('get_val_by_idx', get_val_by_idx)
