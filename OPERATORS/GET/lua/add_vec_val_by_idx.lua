local lVector     = require 'Q/RUNTIME/lua/lVector'
local base_qtype  = require 'Q/UTILS/lua/is_base_qtype'
local qconsts     = require 'Q/UTILS/lua/q_consts'
local ffi = require 'ffi'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local cmem        = require 'libcmem'
local qc          = require 'Q/UTILS/lua/q_core'
local Scalar      = require 'libsclr'
local record_time = require 'Q/UTILS/lua/record_time'

local function add_vec_val_by_idx(idx, src, dst, optargs)
  assert(idx and type(idx) == "lVector", "idx must be a Vector")
  assert(src and type(src) == "lVector", "src must be a Vector")
  assert(dst and type(dst) == "lVector", "dst must be a Vector")
  if ( not dst:is_eov() ) then dst:eval() end 
  assert(dst:is_eov(), "dst must be materialized")
  local nR_dst = dst:length()

  local sp_fn_name = "Q/OPERATORS/GET/lua/add_vec_val_by_idx_specialize"
  local spfn = assert(require(sp_fn_name))
  assert(src:fldtype() == dst:fldtype(), 
    "for now, src:fldtype() == dst:fldtype(). These are " ..
    src:fldtype()  .. " => " ..  dst:fldtype())
  local status, subs = pcall(spfn, idx:fldtype(), dst:fldtype(), 
    optargs)
  if not status then print(subs) end
  assert(status, "Error in specializer " .. sp_fn_name)
  local func_name = assert(subs.fn)

  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation

  assert(qc[func_name], "Symbol not available" .. func_name)

  --=====================================
  local dst_len, dst_ptr, nn_dst_ptr = dst:start_write()
  assert(dst_len == nR_dst)
  local dst_cast_as = subs.val_ctype .. "*"
  local cst_dst_ptr = ffi.cast(dst_cast_as,  get_ptr(dst_ptr))

  local src_len, src_chunk
  local src_cast_as = subs.val_ctype .. "*"

  local idx_len, idx_chunk
  local idx_cast_as = subs.idx_ctype .. "*"

  local chunk_idx = 0
  while true do 
    src_len, src_chunk = src:chunk(chunk_idx)
    if src_len == 0 then break end 
    idx_len, idx_chunk = idx:chunk(chunk_idx)
    local src_chunk = ffi.cast(src_cast_as,  get_ptr(src_chunk))
    local idx_chunk = ffi.cast(idx_cast_as,  get_ptr(idx_chunk))

    local start_time = qc.RDTSC()
    qc[func_name](idx_chunk, idx_len, src_chunk, cst_dst_ptr, nR_dst)
    record_time(start_time, func_name)
    chunk_idx = chunk_idx + 1
  end
  dst:end_write()
  return dst
end

return require('Q/q_export').export('add_vec_val_by_idx', add_vec_val_by_idx)
