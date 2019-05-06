local Q           = require 'Q/q_export'
local qc          = require 'Q/UTILS/lua/q_core'
local ffi         = require 'Q/UTILS/lua/q_ffi'
local cmem        = require 'libcmem'
local qconsts     = require 'Q/UTILS/lua/q_consts'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local lVector     = require 'Q/RUNTIME/lua/lVector'
local function TM_to_I8(
  inv, 
  optargs
  )
  assert(type(inv) == "lVector")
  local in_qtype = "TM"
  assert(inv:fldtype() == in_qtype)
  assert(inv:has_nulls() == false)
  local in_width = inv:field_width()
  
  local in_ctype = qconsts.qtypes[in_qtype].ctype
  local cst_in_as = in_ctype .. " *"
  local out_qtype = "I8"
  local out_ctype = qconsts.qtypes[out_qtype].ctype
  local out_width = qconsts.qtypes[out_qtype].width
  local out_buf 
  local cst_out_buf
  local chunk_idx = 0
  local first_call = true
  local function gen(chunk_num)
    assert(chunk_num == chunk_idx)
    if ( first_call ) then 
      print("XXXX", qconsts.chunk_size * out_width)
      out_buf = cmem.new(qconsts.chunk_size * out_width)
      cst_out_buf = ffi.cast(out_ctype .. " *", get_ptr(out_buf))
      first_call = false
    end
    local len, base_data = inv:chunk(chunk_idx)
    if ( len > 0 ) then 
      local in_ptr = ffi.cast(cst_in_as, get_ptr(base_data))
      local status = qc["TM_to_I8"](in_ptr, len, cst_out_buf)
      assert(status == 0)
      chunk_idx = chunk_idx + 1
    end
    return len, out_buf
  end
  local outv = lVector({qtype = out_qtype, gen = gen, has_nulls = false})
  return outv
end
return require('Q/q_export').export('TM_to_I8', TM_to_I8)
