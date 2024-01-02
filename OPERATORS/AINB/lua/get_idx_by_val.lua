local Q           = require 'Q/q_export'
local qc          = require 'Q/UTILS/lua/qcore'
local lVector     = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local cmem        = require 'libcmem'
local cutils      = require 'libcutils'

local function get_idx_by_val(x, y, optargs)
  local sp_fn_name = "Q/OPERATORS/AINB/lua/get_idx_by_val_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs = pcall(spfn, x, y, optargs)
  if not status then print(subs) end
  print("XXX", type(subs))
  for k, v in pairs(subs) do print(k, v) end 
  local func_name = assert(subs.fn)
  qc.q_add(subs); 
  assert(qc[func_name], "Symbol not available" .. func_name)
  
  local l_chunk_num = 0
  local gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    local out_buf = cmem.new(
      { size = subs.bufsz, qtype = subs.out_qtype, })
    out_buf:zero()
    out_buf:stealable(true)
    local out_ptr = get_ptr(out_buf, subs.cast_out_as)

    local nn_out_buf = cmem.new(
      { size = subs.bufsz, qtype = subs.out_qtype, })
    nn_out_buf:zero()
    nn_out_buf:stealable(true)
    local nn_out_ptr = get_ptr(nn_out_buf, subs.cast_out_as)

    local x_len, x_chunk = x:get_chunk(chunk_num)
    local ycmem, _, y_len   = y:get_lma_write()

    if ( x_len == 0 ) then 
      y:unget_lma_write() -- return access to y
      out_buf:delete(); 
      return 0 
    end 
    local xptr = get_ptr(x_chunk, subs.cast_x_as)
    local yptr = get_ptr(ycmem, subs.cast_y_as)
    local start_time = qc.rdtsc()
    local status = qc[func_name](x_chunk, x_len, yptr, y_len,
      out_ptr, nn_out_ptr)
    x:unget_chunk(chunk_num)
    y:unget_lma_write()
    assert(status == 0)
    record_time(start_time, func)
    l_chunk_num = l_chunk_num + 1
    return x_len, x_chunk
  end
  local vargs = {}
  vargs.gen = gen
  vargs.has_nulls = false
  vargs.qtype = subs.out_qtype
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return lVector(vargs)
end
return require('Q/q_export').export('get_idx_by_val', get_idx_by_val)
