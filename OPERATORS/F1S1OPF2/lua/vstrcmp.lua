local ffi         = require 'ffi'
local cmem        = require 'libcmem'
local cutils      = require 'libcutils'
local qc          = require 'Q/UTILS/lua/qcore'
local lVector     = require 'Q/RUNTIME/VCTR/lua/lVector'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

qc.q_cdef("RUNTIME/SCLR/inc/sclr_struct.h", { "UTILS/inc/" })

local function vstrcmp(f1, s1, optargs )
  local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/vstrcmp_specialize"
  local spfn = assert(require(sp_fn_name))
  --=====================
  local status, subs = pcall(spfn, f1, s1, optargs)
  if not status then print(subs) end
  local func_name = assert(subs.fn)
  qc.q_add(subs)
  local l_chunk_num = 0
  local xs = ffi.cast("SCLR_REC_TYPE *", subs.sclr)
  local sclr_ptr = xs[0].val.str
  --============================================
  local gen = function(chunk_num)
    -- sync between expected chunk_num and generator's l_chunk_num state
    assert(chunk_num == l_chunk_num)
    -- create space for output
    local f2_buf = cmem.new(subs.bufsz)
    f2_buf:zero()
    f2_buf:stealable(true)
    local cst_f2_buf = ffi.cast(subs.cast_f2_as, get_ptr(f2_buf))
    local nn_f2_buf, cst_nn_f2_buf
    if ( subs.has_nulls ) then 
      nn_f2_buf = cmem.new(nn_bufsz)
      nn_f2_buf:zero()
      nn_f2_buf:stealable(true)
      cst_nn_f2_buf = ffi.cast("bool *", get_ptr(nn_f2_buf))
    end
    --=========================================
    local f1_len, f1_buf, nn_f1_buf = f1:get_chunk(l_chunk_num)
    if ( f1_len == 0 ) then 
      f2_buf:delete()
      nn_f2_buf:delete()
      return 0
    end
    --===========================================
    local cst_f1_buf = ffi.cast(subs.cast_f1_as, get_ptr(f1_buf))
    local cst_nn_f1_buf 
    if ( subs.has_nulls ) then 
      cst_nn_f1_buf = ffi.cast("bool *", get_ptr(nn_f1_buf))
    end
    local start_time = cutils.rdtsc()
    qc[func_name](cst_f1_buf, cst_nn_f1_buf, f1_len, subs.in_width,
      sclr_ptr, cst_f2_buf, cst_nn_f2_buf)
    record_time(start_time, func_name)
    f1:unget_chunk(chunk_num)
    l_chunk_num = l_chunk_num + 1
    return f1_len, f2_buf, nn_f2_buf
  end
  local vargs = {}
  if ( optargs ) then 
    assert(type(optargs) == "table")
    for k, v in pairs(optargs) do vargs[k] = v end 
  end
  vargs.gen = gen
  vargs.has_nulls = subs.has_nulls
  vargs.qtype = subs.out_qtype
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return lVector(vargs)
end
return require('Q/q_export').export('vstrcmp', vstrcmp)
