local Q             = require 'Q/q_export'
local qc            = require 'Q/UTILS/lua/q_core'
local ffi           = require 'ffi'
local cmem          = require 'libcmem'
local cVector       = require 'libvctr'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local record_time   = require 'Q/UTILS/lua/record_time'
local lVector       = require 'Q/RUNTIME/VCTR/lua/lVector'
local function SC_to_XX(
  invec, 
  lfn, -- Lua function 
  out_qtype
  )
  assert(type(invec) == "lVector")
  assert(type(lfn) == "function")
  assert(type(out_qtype) == "string")
  assert(is_base_qtype(out_qtype))
  assert(invec:fldtype() == "SC")
  assert(invec:has_nulls() == false)
  local in_width = invec:field_width()
  
  local chunk_size = cVector.chunk_size()
  local out_ctype = qconsts.qtypes[out_qtype].ctype
  local out_width = qconsts.qtypes[out_qtype].width
  local buf = cmem.new(0)
  local chunk_idx = 0
  local first_call = true
  local function gen(chunk_num)
    assert(chunk_num == chunk_idx)
    if ( not buf:is_data() ) then 
      buf = cmem.new(
        { size = chunk_size * out_width, qtype = out_qtype})
      buf:stealable(true)
    end
    local cst_buf = get_ptr(buf, out_ctype .. " *")
    local len, base_data = invec:get_chunk(chunk_idx)
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
    chunk_idx = chunk_idx + 1
    return out_len, buf
  end
  local outv = lVector({qtype = out_qtype, gen = gen, has_nulls = false})
  return outv
end
return require('Q/q_export').export('SC_to_XX', SC_to_XX)
