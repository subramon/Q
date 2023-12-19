local ffi     = require 'ffi'
local qc      = require 'Q/UTILS/lua/qcore'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function custom1_extract(f1, s1, optargs )
  local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/custom1_extract_specialize"
  local spfn = assert(require(sp_fn_name))
  --=====================
  local status, subs = pcall(spfn, f1, s1, optargs)
  if not status then print(subs) end
  local func_name = assert(subs.fn)
  qc.q_add(subs)
  local l_chunk_num = 0
  --============================================
  local gen = function(chunk_num)
    -- sync between expected chunk_num and generator's l_chunk_num state
    assert(chunk_num == l_chunk_num)
    -- create space for output
    local f2_buf = cmem.new(subs.bufsz)
    f2_buf:zero()
    f2_buf:stealable(true)
    local cast_f2_buf = ffi.cast(subs.cast_f2_as, get_ptr(f2_buf))

    local nn_f2_buf = cmem.new(subs.nn_bufsz)
    nn_f2_buf:zero()
    nn_f2_buf:stealable(true)
    local cast_nn_f2_buf = ffi.cast(subs.cast_nn_f2_as, get_ptr(nn_f2_buf))
    --=========================================
    local f1_len, f1_buf = f1:get_chunk(l_chunk_num)
    if ( f1_len == 0 ) then 
      f2_buf:delete()
      nn_f2_buf:delete()
      return 0
    end
    --===========================================
    local cast_f1_buf = ffi.cast(subs.cast_f1_as, get_ptr(f1_buf))
    local start_time = cutils.rdtsc()
    qc[func_name](cast_f1_buf, f1_len, cast_f2_buf, cast_nn_f2_buf)
    record_time(start_time, func_name)
    f1:unget_chunk(chunk_num)
    l_chunk_num = l_chunk_num + 1
    return f1_len, f2_buf, nn_f2_buf
  end
  local vargs = {}
  vargs.gen       = gen
  vargs.has_nulls = subs.has_nulls
  vargs.qtype     = subs.out_qtype
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return lVector(vargs)
end
return require('Q/q_export').export('custom1_extract', custom1_extract)
