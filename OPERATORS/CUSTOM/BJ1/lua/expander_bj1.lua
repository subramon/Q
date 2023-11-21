local cutils   = require 'libcutils'
local cmem     = require 'libcmem'
local lgutils  = require 'liblgutils'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local qc       = require 'Q/UTILS/lua/qcore'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_bj1(
  dst_pk, dst_t_start, dst_t_stop,
  src_pk, src_t_start, src_t_stop, src_val, optargs)
  local specializer = "Q/OPERATORS/bj1/lua/bj1_specialize"
  local spfn = assert(require(specializer))
  local subs = assert(spfn(x, 
    dst_pk, dst_t_start, dst_t_stop,
    src_pk, src_t_start, src_t_stop, src_val, optargs))
  assert(type(subs) == "table")
  local func_name = assert(subs.fn)
  qc.q_add(subs)
  local l_chunk_num = 0

  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    -- create output buffers
    local dst_val_chunk = assert(cmem.new(subs.bufsz))
    dst_val_chunk:stealable(true)
    local nn_dst_val_chunk = assert(cmem.new(subs.nn_bufsz))
    nn_dst_val_chunk:stealable(true)
    -- get next chunk of inputs 
    dst_pk_len, dst_pk_chunk = dst_pk:get_chunk(l_chunk_num)
    dst_t_start_len, dst_t_start_chunk = dst_t_start:get_chunk(l_chunk_num)
    dst_t_stop_len, dst_t_stop_chunk = dst_t_stop:get_chunk(l_chunk_num)
    -- START: check compatibilty of return values
    assert(dst_pk_len == dst_t_start_len)
    assert(dst_pk_len == dst_t_stop_len)
    if ( dst_pk_chunk ) then assert(dst_t_start_chunk) end 
    if ( dst_pk_chunk ) then assert(dst_t_stop_chunk) end 
    if ( not dst_pk_chunk ) then assert(not dst_t_start_chunk) end 
    if ( not dst_pk_chunk ) then assert(not dst_t_stop_chunk) end 
    -- STOP : check compatibilty of return values
    -- return if nothing to do 
    if ( dst_pk_len == 0 ) then 
      dst_val_chunk:delete()
      nn_dst_val_chunk:delete()
      return 0
    end
    -- get access to destination tables
    local dst_pk_ptr = get_ptr(dst_pk_chunk, subs.pk_cast_as)
    local dst_t_start_ptr = get_ptr(dst_t_start_chunk, subs.tim_cast_as)
    local dst_t_stop_ptr = get_ptr(dst_t_stop_chunk, subs.tim_cast_as)
    local dst_val_ptr = get_ptr(dst_val_chunk, subs.val_cast_as)
    local nn_dst_val_ptr = get_ptr(nn_dst_val_chunk, "uint8_t *")
    -- get access to source tables
    -- TODO 
    -- invoke function
    qc[func_name](dst_pk_ptr, dst_t_start_ptr, dst_t_stop_ptr, dst_pk_len,
      dst_val_ptr, nn_dst_val_ptr, 
      src_pk_ptr, src_t_start_ptr, src_t_stop_ptr, src_pk_len, src_val_ptr)
    -- release resources
    dst_pk:unget_chunk(l_chunk_num)
    dst_t_start:unget_chunk(l_chunk_num)
    dst_t_stop:unget_chunk(l_chunk_num)
    -- return
    return dst_pk_len, dst_val_chunk, nn_dst_val_chunk
  end
  local vargs = {
    gen = gen, qtype = subs.val_qtype, has_nulls = true,
    max_num_in_chunk = dst_pk:max_num_in_chunk()}
   return lVector(vargs)
end
return expander_bj1
