local ffi     = require 'ffi'
local qc      = require 'Q/UTILS/lua/qcore'
local is_in   = require 'Q/UTILS/lua/is_in'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function is_prev(f1, cmp, optargs )
  local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/is_prev_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs = pcall(spfn, f1, cmp, optargs)
  if not status then print(subs) end
  local func_name = assert(subs.fn)
  if ( not qc[func_name] ) then qc.q_add(subs, func_name) end
  assert(qc[func_name], "Missing symbol " .. func_name)
  --======================
  local chunk_idx = 0
  local last_val = cmem.new({ size = ffi.sizeof(subs.in_ctype)})
  local cst_last_val = ffi.cast(subs.f1_cast_as, get_ptr(last_val))
  --============================================
  local first_call = true
  local f2_gen = function(chunk_num)
    -- sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    local f2_buf = cmem.new(subs.bufsz)
    f2_buf:zero()
    f2_buf:stealable(true)
    local cst_f2_buf = ffi.cast(subs.f2_cast_as, get_ptr(f2_buf))
    local f1_len, f1_buf, _ = f1:get_chunk(chunk_idx)
    if ( f1_len == 0 ) then return 0 end 
    --===========================================
    local cst_f1_buf = ffi.cast(subs.f1_cast_as, get_ptr(f1_buf))
    local start_time = cutils.rdtsc()
    qc[func_name](cst_f1_buf, f1_len, subs.default_val, first_call,
      cst_f2_buf, cst_last_val)
    record_time(start_time, func_name)
    f1:unget_chunk(chunk_idx)
    first_call = false
    chunk_idx = chunk_idx + 1
    if ( f1_len < subs.max_num_in_chunk ) then last_val:delete() end -- no more calls 
    return f1_len, f2_buf
  end
  local vargs = {}
  if ( optargs ) then 
    assert(type(optargs) == "table")
    for k, v in pairs(optargs) do vargs[k] = v end 
  end
  vargs.gen = f2_gen
  vargs.has_nulls = false
  vargs.qtype = subs.out_qtype
  vargs.max_num_in_chunk = subs.max_num_in_chunk
  return lVector(vargs)
end
return require('Q/q_export').export('is_prev', is_prev)
