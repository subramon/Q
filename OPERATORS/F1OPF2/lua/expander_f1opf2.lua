local ffi      = require 'ffi' 
local cutils   = require 'libcutils' 
local qc       = require 'Q/UTILS/lua/qcore'
local lVector  = require 'Q/RUNTIME/VCTRS/lua/lVector'
local cmem     = require 'libcmem'
local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local function expander_f1opf2(a, f1, optargs )
  local sp_fn_name = "Q/OPERATORS/F1OPF2/lua/" .. a .. "_specialize"
  local spfn = assert(require(sp_fn_name))
  optargs = optargs or {}
  optargs.__operator = a -- for use in specializer if needed
  local subs = assert(spfn(f1, optargs))

  local func_name = assert(subs.fn)
  qc.q_add(subs); 

  local l_chunk_num = 0
  --============================================
  local f2_gen = function(chunk_num)
    assert(chunk_num == l_chunk_num)
    local buf = assert(cmem.new(
      {size = subs.f2_buf_sz, qtype = subs.f2_qtype}))
    assert(type(buf) == "CMEM")
    buf:stealable(true)
    --========================================
    local f1_len, f1_chunk, _ = f1:get_chunk(l_chunk_num)
    if ( f1_len > 0 ) then 
      local chunk1 = get_ptr(f1_chunk, subs.cast_f1_as)
      local chunk2 = get_ptr(buf,      subs.cast_f2_as)
      local start_time = cutils.rdtsc()
      local status = 
      qc[func_name](chunk1, f1_len, chunk2)
      assert(status == 0)
      record_time(start_time, func_name)
    end
    f1:unget_chunk(l_chunk_num)
    --==================================
    l_chunk_num = l_chunk_num + 1
    return f1_len, buf
  end
  local vargs = optargs 
  vargs.gen = f2_gen
  vargs.has_nulls = false
  vargs.qtype = subs.f2_qtype
  return lVector(vargs)
end 
return expander_f1opf2
