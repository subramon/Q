local lVector     = require 'Q/RUNTIME/VCTRS/lua/lVector'
local ffi         = require 'ffi' 
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local qc          = require 'Q/UTILS/lua/qcore'
local cmem        = require 'libcmem'
local Scalar      = require 'libsclr'
local record_time = require 'Q/UTILS/lua/record_time'

local function get_val_by_idx(x, y, optargs)

  assert(x and type(x) == "lVector", "x must be a Vector")
  assert(y and type(y) == "lVector", "y must be a Vector")
  assert(y:is_eov(), "y must be materialized")
  local nR2 = y:length()

  local sp_fn_name = "Q/OPERATORS/GET/lua/get_val_by_idx_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs = pcall(spfn, x, y, optargs)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  qc.q_add(subs)
  local func_name = assert(subs.fn)
  assert(qc[func_name], "Symbol not available" .. func_name)

  --=====================================

  local l_chunk_num = 0
  local f3_gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    local out_buf = cmem.new( { size = subs.bufsz, qtype = subs.out_qtype})
    out_buf:zero()
    out_buf:stealable(true)
    out_ptr = get_ptr(out_buf, subs.cast_out_as)
    local nn_out_buf; local nn_out_ptr = ffi.NULL
    if ( x:has_nulls() ) then 
      nn_out_buf = cmem.new( { size = subs.nn_bufsz, qtype = subs.nn_out_qtype})
      nn_out_buf:zero()
      nn_out_buf:stealable(true)
      nn_out_ptr = get_ptr(nn_out_buf, subs.cast_nn_out_as)
    end

    local f2_len, f2_ptr = y:get_all()
    assert(f2_len == nR2)
    local ptr2 = ffi.cast(f2_cast_as,  get_ptr(f2_ptr))

    local x_len, x_chunk, nn_x_chunk = x:get_chunk(chunk_num)
    local x_ptr = get_ptr(x_chunk, subs.cast_x_as)
    local nn_x_ptr
    if ( nn_x_chunk ) then 
      nn_x_ptr = get_ptr(nn_x_chunk, subs.cast_nn_x_as)
    end
    if ( x_len == 0 ) then
      out_buf:delete()
      if ( nn_out_buf ) then nn_out_buf:delete() end
      return 0
    end 
    local start_time = qc.RDTSC()
    local status = qc[func_name](xptr, x_len, yptr, y_len, out_ptr, nn_out_ptr) 
    x:unget_chunk(chunk_num)
    assert(status == 0)
    l_chunk_num = l_chunk_num + 1 
    return x_len, out_buf, nn_out_buf
  end
  local vargs = {}
  vargs.gen = gen 
  vargs.qtype = subs.out_qtype
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  vargs.has_nulls = subs.out_has_nulls
  return lVector(vargs)
end

return require('Q/q_export').export('get_val_by_idx', get_val_by_idx)
