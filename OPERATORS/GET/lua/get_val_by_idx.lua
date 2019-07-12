local function get_val_by_idx(x, y, optargs)
  local lVector     = require 'Q/RUNTIME/lua/lVector'
  local base_qtype  = require 'Q/UTILS/lua/is_base_qtype'
  local qconsts     = require 'Q/UTILS/lua/q_consts'
  local ffi         = require 'Q/UTILS/lua/q_ffi'
  local get_ptr     = require 'Q/UTILS/lua/get_ptr'
  local qc          = require 'Q/UTILS/lua/q_core'
  local cmem        = require 'libcmem'
  local Scalar      = require 'libsclr'
  local record_time = require 'Q/UTILS/lua/record_time'

  assert(x and type(x) == "lVector", "x must be a Vector")
  assert(y and type(y) == "lVector", "y must be a Vector")
  assert(y:is_eov(), "y must be materialized")
  local nR2 = y:length()

  local sp_fn_name = "Q/OPERATORS/GET/lua/get_val_by_idx_specialize"
  local spfn = assert(require(sp_fn_name))
  local status, subs, tmpl = pcall(spfn, x:fldtype(), y:fldtype(), 
    optargs)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Symbol not available" .. func_name)

  --=====================================
  local f2_cast_as = subs.in2_ctype .. "*" 
  local null_val = assert(subs.null_val)
  assert(type(null_val) == "Scalar")
  local ptr_null_val = ffi.cast(f2_cast_as,  get_ptr(null_val:to_cmem()))
  --=====================================

  local f3_qtype = assert(subs.out_qtype)
  local f3_width = qconsts.qtypes[f3_qtype].width
  local buf_sz = qconsts.chunk_size * f3_width
  local f3_buf = nil

  local first_call = true
  local chunk_idx = 0
  local myvec 
  local f3_gen = function(chunk_num)
    
    -- Adding assert on chunk_idx to have sync between expected 
    -- chunk_num and generator's chunk_idx state
    assert(chunk_num == chunk_idx, 
      "chunk_num = " .. chunk_num  .. "chunk_idx = " .. chunk_idx)
    if ( first_call ) then 
      first_call = false
      f3_buf = assert(cmem.new(buf_sz, f3_qtype))
      myvec:no_memcpy(f3_buf) -- hand control of this f3_buf to the vector 
    end
    local f3_cast_as = subs.out_ctype .. "*"

    local f2_len, f2_ptr = y:get_all()
    assert(f2_len == nR2)
    local ptr2 = ffi.cast(f2_cast_as,  get_ptr(f2_ptr))

    local f1_len, f1_chunk, nn_f1_chunk
    f1_len, f1_chunk, nn_f1_chunk = x:chunk(chunk_idx)
    local f1_cast_as = subs.in1_ctype .. "*"

    if f1_len > 0 then
      local chunk1 = ffi.cast(f1_cast_as,  get_ptr(f1_chunk))
      local chunk3 = ffi.cast(f3_cast_as,  get_ptr(f3_buf))
      local start_time = qc.RDTSC()
      qc[func_name](chunk1, ptr2, f1_len, nR2, ptr_null_val, chunk3)
      record_time(start_time, func_name)
    else
      f3_buf = nil
    end
    chunk_idx = chunk_idx + 1
    return f1_len, f3_buf
  end
  myvec = lVector{gen=f3_gen, nn=false, qtype=f3_qtype, has_nulls=false}
  return myvec
end

return require('Q/q_export').export('get_val_by_idx', get_val_by_idx)
