local ffi      = require 'ffi' 
local cutils   = require 'libcutils' 
local Scalar   = require 'libsclr'
local qc       = require 'Q/UTILS/lua/qcore'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local cmem     = require 'libcmem'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_f1s1opf2(op, f1, sclrs, optargs )
  local sp_fn_name = "Q/OPERATORS/F1SnOPF2/lua/" .. op .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  local subs = assert(spfn(op, f1, sclrs, optargs))
  local func_name = assert(subs.fn)
  qc.q_add(subs); 

  local l_chunk_num = 0
  --============================================
  local f2_gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    -- IMPORTANT: I still don't fully understand why the following
    -- is needed. Has to do with LuaJIT garbage collecting early
    local ptr_to_sclrs = get_ptr(subs.sclr_array, subs.qtype)
    local buf = assert(cmem.new(
      {size = subs.f2_buf_sz, qtype = subs.f2_qtype}))
    assert(type(buf) == "CMEM")
    buf:stealable(true)
    local nn_buf
    if ( subs.has_nulls ) then 
      error("TO BE TESTED")
      nn_buf = assert(cmem.new(
        {size = subs.nn_f2_buf_sz, qtype = subs.nn_f2_qtype}))
      nn_buf:stealable(true)
    end
    --========================================
    local f1_len, f1_chunk, nn_f1_chunk = f1:get_chunk(l_chunk_num)
    if ( f1_len == 0 ) then 
      buf:delete()
      if ( nn_buf ) then nn_buf:delete() end 
      subs.sclr_array:delete()
      f1:kill()
      return 0
    end
    --========================================
    local chunk1 = get_ptr(f1_chunk, subs.qtype)
    local chunk2 = get_ptr(buf,      subs.f2_qtype)
    local start_time = cutils.rdtsc()
    local status 
    if ( subs.has_nulls ) then 
      error("TO BE TESTED")
      local nn_chunk1 = get_ptr(nn_f1_chunk, "bool *") -- TODO handle B1
      local nn_chunk2 = get_ptr(nn_buf, "bool *") -- TODO handle B1
      status = qc[func_name](chunk1, nn_chunk1, f1_len, ptr_to_sclrs,
        chunk2, nn_chunk2)
    else
      status = qc[func_name](chunk1, f1_len, subs.ptr_to_sclrs, 
        subs.num_sclrs, chunk2)
    end
    assert(status == 0)
    record_time(start_time, func_name)
    f1:unget_chunk(l_chunk_num)
    --==================================
    l_chunk_num = l_chunk_num + 1
    if ( f1_len < subs.max_num_in_chunk ) then 
      subs.sclr_array:delete()
      f1:kill()
    end
    return f1_len, buf, nn_buf
  end
  local vargs = optargs 
  vargs.gen = f2_gen
  if ( subs.has_nulls ) then 
    vargs.has_nulls = true 
  else
    vargs.has_nulls = false
  end
  vargs.qtype = subs.f2_qtype
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return  lVector(vargs)
end 
return expander_f1s1opf2
