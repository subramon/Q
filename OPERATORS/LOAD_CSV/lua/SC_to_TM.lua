local Q           = require 'Q/q_export'
local qc          = require 'Q/UTILS/lua/q_core'
local ffi         = require 'Q/UTILS/lua/q_ffi'
local cmem        = require 'libcmem'
local qconsts     = require 'Q/UTILS/lua/q_consts'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local lVector     = require 'Q/RUNTIME/lua/lVector'
local function SC_to_TM(
  inv, 
  format,
  optargs
  )
  assert(type(inv) == "lVector")
  assert(inv:fldtype() == "SC")
  assert(inv:has_nulls() == false)
  local in_width = inv:field_width()
  assert(type(format) == "string")
  assert(#format > 0)
  
  local out_qtype = "TM"
  local out_ctype = qconsts.qtypes[out_qtype].ctype
  local out_width = qconsts.qtypes[out_qtype].width
  local out_buf 
  local cst_out_buf
  local chunk_idx = 0
  local first_call = true
  local function gen(chunk_num)
    assert(chunk_num == chunk_idx)
    if ( first_call ) then 
      out_buf = cmem.new(qconsts.chunk_size * out_width, out_qtype)
      cst_out_buf = ffi.cast(out_ctype .. "  *", get_ptr(out_buf))
      first_call = false
    end
    local len, base_data = inv:chunk(chunk_idx)
    if ( len > 0 ) then 
      local ptr_to_chars = ffi.cast("char *", get_ptr(base_data))
      local status = qc["SC_to_TM"](
        ptr_to_chars, in_width, len, format, cst_out_buf)
      assert(status == 0)
      chunk_idx = chunk_idx + 1
    end
    return len, out_buf
  end
  local outv = lVector({qtype = out_qtype, gen = gen, has_nulls = false})
  return outv
end
return require('Q/q_export').export('SC_to_TM', SC_to_TM)
