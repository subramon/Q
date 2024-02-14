local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local cVector = require 'libvctr'
local cutils  = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qc      = require 'Q/UTILS/lua/qcore'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local is_in   = require 'Q/UTILS/lua/is_in'
local record_time = require 'Q/UTILS/lua/record_time'
local copy_optargs_to_vctr_args = require 'Q/UTILS/lua/copy_optargs_to_vctr_args'


local function expander_f1f2opf3(op, f1, f2, optargs )
  local sp_fn_name = "Q/OPERATORS/F1F2OPF3/lua/" .. op .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  local subs = assert(spfn(op, f1, f2, optargs))
  -- subs should return 
  -- (1) f3_qtype (2) f1_cst_as (2) f2_cst_as (3) f3_cst_as
  local func_name = assert(subs.fn)
  qc.q_add(subs)

  local l_chunk_num = 0
  local f3_gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    local buf = assert(cmem.new(
      {size = subs.bufsz, qtype = subs.f3_qtype}))
    buf:stealable(true)
    local nn_buf
    if ( subs.has_nulls ) then 
      nn_buf = assert(cmem.new(
        {size = subs.nn_bufsz, qtype = subs.nn_f3_qtype}))
      nn_buf:stealable(true)
    end
    --=============================
    local f1_len, f1_chunk, nn_f1_chunk
    local f2_len, f2_chunk, nn_f2_chunk
    f1_len, f1_chunk, nn_f1_chunk = f1:get_chunk(l_chunk_num)
    f2_len, f2_chunk, nn_f2_chunk = f2:get_chunk(l_chunk_num)
    assert(f1_len == f2_len)
    -- early exit 
    if ( f1_len == 0 ) then 
      buf:delete()
      nn_buf:delete()
      if ( subs.cargs ) then subs.cargs:delete() end 
      f1:kill() 
      f2:kill()
      return 0 
    end
    -- following prefetch is experimental as of Feb 2023
    -- f1:prefetch(l_chunk_num+1)
    -- f2:prefetch(l_chunk_num+1)
    --==================
    local chunk1 = get_ptr(f1_chunk, subs.f1_cast_as)
    local chunk2 = get_ptr(f2_chunk, subs.f2_cast_as)
    local chunk3 = get_ptr(buf,      subs.f3_cast_as)
    local start_time = cutils.rdtsc()
    local status 
    if ( subs.has_nulls ) then 
      local nn_chunk1 = get_ptr(nn_f1_chunk, "bool *")
      local nn_chunk2 = get_ptr(nn_f2_chunk, "bool *")
      local nn_chunk3 = get_ptr(nn_buf, "bool *")
      status = qc[func_name](chunk1, nn_chunk1, chunk2, nn_chunk2, f1_len, 
        subs.cst_cargs, chunk3, nn_chunk3)
    else
      status = qc[func_name](chunk1, chunk2, f1_len, subs.cst_cargs, chunk3)
    end
    assert(status == 0)
    record_time(start_time, func_name)

    f1:unget_chunk(l_chunk_num)
    f2:unget_chunk(l_chunk_num)
    if ( f1_len < subs.max_num_in_chunk ) then 
      assert(f1:is_eov())
      assert(f2:is_eov())
      if ( subs.cargs ) then subs.cargs:delete() end 
      f1:kill(); 
      f2:kill();
    end
    l_chunk_num = l_chunk_num + 1
    return f1_len, buf, nn_buf
  end
  local vargs = copy_optargs_to_vctr_args(optargs)

  vargs.gen = f3_gen
  vargs.qtype=subs.f3_qtype
  vargs.has_nulls=false 
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return lVector(vargs)
end
return expander_f1f2opf3
