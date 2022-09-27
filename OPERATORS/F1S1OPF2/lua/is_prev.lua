local ffi     = require 'ffi'
local qc      = require 'Q/UTILS/lua/qcore'
local is_in   = require 'Q/UTILS/lua/is_in'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local cmem    = require 'libcmem'
local cutils  = require 'libcutils'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'

local cmps = { "gt", "lt", "geq", "leq", "eq", "neq" }
local function is_prev(f1, cmp, optargs )
  local sp_fn_name = "Q/OPERATORS/F1S1OPF2/lua/is_prev_specialize"
  local spfn = assert(require(sp_fn_name))
  assert(type(f1) == "lVector")
  local max_num_in_chunk = f1:max_num_in_chunk()
  assert(type(cmp) == "string")
  assert(is_in(cmp, cmps))
  local in_qtype = f1:qtype()
  local status, subs = pcall(spfn, in_qtype, cmp, optargs)
  if not status then print(subs) end
  local default_val = subs.default_val
  assert(type(default_val) == "boolean")
  assert(status, "Specializer " .. sp_fn_name .. " failed")
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs, func_name) print("Dynamic compilation ... ")
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Missing symbol " .. func_name)
  local in_qtype = assert(subs.in_qtype)
  local out_qtype = assert(subs.out_qtype)
  local bufsz 
  if ( out_qtype == "B1" ) then 
    bufsz = max_num_in_chunk / 8
  else
    bufsz = max_num_in_chunk * cutils.get_width_qtype(out_qtype)
  end
  local chunk_idx = 0
  local f1_cast_as = subs.in_ctype .. "*" 
  local f2_cast_as = subs.out_ctype .. "*" 
  local last_val = assert(cmem.new({ size = ffi.sizeof(subs.in_ctype)}))
  local cst_last_val = ffi.cast(f1_cast_as, get_ptr(last_val))
  --============================================
  local first_call = true
  local f2_gen = function(chunk_num)
    -- sync between expected chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx)
    local f2_buf = assert(cmem.new(bufsz))
    local cst_f2_buf = ffi.cast(f2_cast_as, get_ptr(f2_buf))
    f2_buf:zero()
    local f1_len, f1_buf, _ = f1:get_chunk(chunk_idx)
    if f1_len > 0 then  
      local cst_f1_buf = ffi.cast(f1_cast_as, get_ptr(f1_buf))
      local start_time = cutils.rdtsc()
      qc[func_name](cst_f1_buf, f1_len, default_val, first_call,
      cst_f2_buf, cst_last_val)
      record_time(start_time, func_name)
    end
    first_call = false
    chunk_idx = chunk_idx + 1
    return f1_len, f2_buf
  end
  return lVector{gen=f2_gen, has_nulls=false, qtype=out_qtype}
end
return require('Q/q_export').export('is_prev', is_prev)
