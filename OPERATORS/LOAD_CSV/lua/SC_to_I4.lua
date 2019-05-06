local Q           = require 'Q/q_export'
local qc          = require 'Q/UTILS/lua/q_core'
local ffi         = require 'Q/UTILS/lua/q_ffi'
local cmem        = require 'libcmem'
local qconsts     = require 'Q/UTILS/lua/q_consts'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local lVector     = require 'Q/RUNTIME/lua/lVector'
local function SC_to_I4(
  inv, 
  dict,
  optargs
  )
  assert(type(inv) == "lVector")
  assert(type(dict) == "table")
  assert(inv:fldtype() == "SC")
  assert(inv:has_nulls() == false)
  local in_width = inv:field_width()
  
  local out_qtype = "I4"
  if ( optargs ) then
    assert(type(optargs) == "table")
    if ( optargs.qtype ) then
      out_qtype = assert(optargs.qtype)
      assert(type(out_qtype) == "string")
      assert( ( out_qtype == "I1" ) or ( out_qtype == "I2" ) or
            ( out_qtype == "I4" ) or ( out_qtype == "I8" ) )
    end
  end
  local out_ctype = qconsts.qtypes[out_qtype].ctype
  local out_width = qconsts.qtypes[out_qtype].width
  local out_buf 
  local cst_out_buf
  local chunk_idx = 0
  local first_call = true
  local function gen(chunk_num)
    assert(chunk_num == chunk_idx)
    if ( first_call ) then 
      out_buf = cmem.new(qconsts.chunk_size * out_width, out_qtype, "test")
      cst_out_buf = ffi.cast(out_ctype .. "  *", get_ptr(out_buf))
      first_call = false
    end
    local len, base_data = inv:chunk(chunk_idx)
    local ptr_to_chars = ffi.cast("char *", get_ptr(base_data))
    local out_len = 0
    for i = 1, len do
      local in_str = ffi.string(ptr_to_chars) -- , in_width)
      local out_id = dict[in_str]
      if ( not out_id ) then
        out_id = 0
      else
        assert( ( type(out_id) == "number") and (out_id > 0 ))
      end
      cst_out_buf[out_len] = out_id
      out_len   = out_len   + 1
      ptr_to_chars = ptr_to_chars + in_width
    end
    assert(out_len == len)
    chunk_idx = chunk_idx + 1
    return out_len, out_buf
  end
  local outv = lVector({qtype = out_qtype, gen = gen, has_nulls = false})
  return outv
end
return require('Q/q_export').export('SC_to_I4', SC_to_I4)
