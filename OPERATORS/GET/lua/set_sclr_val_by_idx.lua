local function set_sclr_val_by_idx(x, y, optargs)
  local lVector     = require 'Q/RUNTIME/lua/lVector'
  local base_qtype  = require 'Q/UTILS/lua/is_base_qtype'
  local qconsts     = require 'Q/UTILS/lua/q_consts'
  local ffi = require 'ffi' 
  local get_ptr     = require 'Q/UTILS/lua/get_ptr'
  local cmem        = require 'libcmem'
  local Scalar      = require 'libsclr'
  local record_time = require 'Q/UTILS/lua/record_time'
  local qc          = require 'Q/UTILS/lua/q_core'

  assert(x and type(x) == "lVector", "x must be a Vector")
  assert(y and type(y) == "lVector", "y must be a Vector")
  if ( not y:is_eov() ) then y:eval() end 
  assert(y:is_eov(), "y must be materialized")
  local nR2 = y:length()

  local sp_fn_name = "Q/OPERATORS/GET/lua/set_sclr_val_by_idx_specialize"
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
  --STOP: Dynamic compilation

  assert(qc[func_name], "Symbol not available" .. func_name)

  --=====================================
  local f2_cast_as = subs.val_ctype .. "*" 
  local sclr_val = assert(subs.sclr_val)
  assert(type(sclr_val) == "Scalar")
  local ptr_sclr_val = ffi.cast(f2_cast_as,  get_ptr(sclr_val:to_cmem()))
  --=====================================

  local chunk_idx = 0
  local f2_len, f2_ptr, nn_f2_ptr = y:start_write()
  assert(f2_len == nR2)
  local ptr2 = ffi.cast(f2_cast_as,  get_ptr(f2_ptr))

  while true do 
    local f1_len, f1_chunk, nn_f1_chunk
    f1_len, f1_chunk, nn_f1_chunk = x:chunk(chunk_idx)
    local f1_cast_as = subs.idx_ctype .. "*"

    if f1_len == 0 then break end 
    local chunk1 = ffi.cast(f1_cast_as,  get_ptr(f1_chunk))
    local start_time = qc.RDTSC()
    qc[func_name](chunk1, f1_len, ptr2, nR2, ptr_sclr_val)
    record_time(start_time, func_name)
    chunk_idx = chunk_idx + 1
  end
  y:end_write()
  return y
end

return require('Q/q_export').export('set_sclr_val_by_idx', set_sclr_val_by_idx)
