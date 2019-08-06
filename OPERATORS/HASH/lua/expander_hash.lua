local get_ptr  = require 'Q/UTILS/lua/get_ptr'
local ffi = require 'ffi'
local qconsts  = require 'Q/UTILS/lua/q_consts'
local qc       = require 'Q/UTILS/lua/q_core'
local cmem     = require 'libcmem'
local lVector   = require 'Q/RUNTIME/lua/lVector'
local record_time = require 'Q/UTILS/lua/record_time'
local mem_initialize = require 'Q/OPERATORS/HASH/lua/hash_mem_initialize'

local function expander_hash(f1, optargs)
  -- verification
  assert(type(f1) == "lVector", "input to hash() is not lVector")
  assert(f1:has_nulls() == false, "not prepared for nulls in hash")
  local spfn_name = "Q/OPERATORS/HASH/lua/hash_specialize"
  local spfn = assert(require(spfn_name))
  -- TODO: replace f1:meta().base with f1:lite_meta()
  -- lite_meta() will have vec basic info including vec_nn info
  -- without complex table structure
  local status, subs, tmpl = pcall(spfn, f1:meta().base, optargs)
  if not status then print(subs) end
  assert(status, "Specializer " .. spfn_name .. " failed")
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  -- RS: remove the if as per our earlier discussion
  if ( not qc[func_name] ) then
    print("Dynamic compilation kicking in... ")
    qc.q_add(subs, tmpl, func_name)
  end
  assert(qc[func_name], "Missing symbol " .. func_name)

  local cst_args = mem_initialize(subs)
  local out_qtype = assert(subs.out_qtype)
  local cst_f1_as  = subs.in_ctype  .. "*"
  local cst_out_as = subs.out_ctype .. "*"
  local out_width = qconsts.qtypes[out_qtype].width
  local buf_sz = qconsts.chunk_size * out_width
  local out_buf = nil
  local first_call = true
  local chunk_idx = 0
  --============================================
  local function hash_gen(chunk_num)
    assert(chunk_num == chunk_idx)
    if ( first_call ) then
      -- We have delayed the malloc in generator function
      out_buf = assert(cmem.new(buf_sz, out_qtype))
      first_call = false
    end
    local f1_len, f1_chunk, nn_f1_chunk = f1:chunk(chunk_idx)
    if f1_len == 0 then return 0, nil end

    local cst_f1_chunk  = ffi.cast("char *", get_ptr(f1_chunk))
    local cst_out_buf   = ffi.cast(cst_out_as, get_ptr(out_buf))
    local start_time = qc.RDTSC()
    qc[func_name](cst_f1_chunk, ffi.NULL, f1_len, cst_args,
      cst_out_buf, ffi.NULL)
    record_time(start_time, func_name)
    chunk_idx = chunk_idx + 1
    return f1_len, out_buf
  end
  return lVector{gen=hash_gen, has_nulls=false, qtype=out_qtype}
end
return expander_hash
