-- Provides a slow but easy way to convert a string into a number
local qc            = require 'Q/UTILS/lua/qcore'
local ffi           = require 'ffi'
local cmem          = require 'libcmem'
local cutils        = require 'libcutils'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local lVector       = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qcfg          = require 'Q/UTILS/lua/qcfg'
local function SC_to_XX(
  invec, 
  lfn, -- Lua function 
  out_qtype,
  optargs 
  )
  assert(type(invec) == "lVector")
  assert(type(lfn) == "function")
  assert(type(out_qtype) == "string")
  assert(is_base_qtype(out_qtype))
  assert(invec:qtype() == "SC")
  assert(invec:has_nulls() == false)
  local in_width = invec:width()
  
  local out_ctype = cutils.str_qtype_to_str_ctype(out_qtype)
  local cast_out_as = out_ctype .. " *"
  local out_width = cutils.get_width_qtype(out_qtype)
  local max_num_in_chunk  = invec:max_num_in_chunk()
  local bufsz = max_num_in_chunk * out_width
  local chunk_idx = 0
  local function gen(chunk_num)
    assert(chunk_num == chunk_idx)
    local buf = cmem.new({ size = bufsz, qtype = out_qtype})
    buf:stealable(true)

    local cst_buf = get_ptr(buf, cast_out_as)
    local len, base_data = invec:get_chunk(chunk_idx)
    assert(type(len) == "number")
    if ( len == 0 ) then return 0, nil end 
    local ptr_to_chars = get_ptr(base_data, "char *")
    local out_len = 0
    for i = 1, len do
      local in_str = ffi.string(ptr_to_chars) -- , in_width)
      local out_val = lfn(in_str)
      assert(type(out_val) == "number")
      cst_buf[out_len] = out_val
      out_len   = out_len   + 1
      ptr_to_chars = ptr_to_chars + in_width
    end
    assert(out_len == len)
    invec:unget_chunk(chunk_idx)
    if ( len <  max_num_in_chunk ) then return len, buf end 
    chunk_idx = chunk_idx + 1
    return len, buf
  end
  local vctr_args
  if ( optargs ) then 
    assert(type(optargs) == "table")
    vctr_args = optargs
  else
    vctr_args = {}
  end
  vctr_args.qtype = out_qtype
  vctr_args.gen = gen
  vctr_args.has_nulls = false
  return lVector(vctr_args)
end
return require('Q/q_export').export('SC_to_XX', SC_to_XX)
