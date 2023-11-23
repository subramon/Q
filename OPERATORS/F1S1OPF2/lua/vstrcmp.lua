local ffi     = require 'ffi'
local qc      = require 'Q/UTILS/lua/qcore'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function vstrcmp(f1, s1, optargs )
  local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/vstrcmp_specialize"
  local spfn = assert(require(sp_fn_name))
  --=====================
  local status, subs = pcall(spfn, f1, s1, optargs)
  if not status then print(subs) end
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs, func_name) print("Dynamic compilation ... ")
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Missing symbol " .. func_name)
  local l_chunk_num = 0
  --============================================
  local gen = function(chunk_num)
    -- sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == l_chunk_num)
    local f2_buf = cmem.new(bufsz)
    f2_buf:zero()
    f2_buf:stealable(true)
    local cst_f2_buf = ffi.cast(cast_f2_as, get_ptr(f2_buf))
    local f1_len, f1_buf = f1:get_chunk(chunk_idx)
    if ( f1_len == 0 ) then 
      f2_buf:delete()
      return 0
    end
    --===========================================
    local cst_f1_buf = ffi.cast(f1_cast_as, get_ptr(f1_buf))
    local start_time = cutils.rdtsc()
    qc[func_name](cst_f1_buf, f1_len, cst_f2_buf)
    record_time(start_time, func_name)
    f1:unget_chunk(chunk_num)
    l_chunk_num = l_chunk_num + 1
    return f1_len, f2_buf
  end
  local vargs = {}
  if ( optargs ) then 
    assert(type(optargs) == "table")
    for k, v in pairs(optargs) do vargs[k] = v end 
  end
  vargs.gen = gen
  vargs.has_nulls = false
  vargs.qtype = subs.out_qtype
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return lVector(vargs)
end
return require('Q/q_export').export('vstrcmp', vstrcmp)
