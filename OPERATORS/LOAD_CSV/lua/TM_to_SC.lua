local Q           = require 'Q/q_export'
local qc          = require 'Q/UTILS/lua/q_core'
local ffi         = require 'ffi'
local cmem        = require 'libcmem'
local qconsts     = require 'Q/UTILS/lua/q_consts'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local lVector     = require 'Q/RUNTIME/VCTR/lua/lVector'
local function TM_to_SC(
  inv, 
  format,
  optargs
  )
  assert(type(inv) == "lVector")
  local in_qtype = "TM"
  assert(inv:fldtype() == in_qtype)
  assert(inv:has_nulls() == false)
  local in_width = inv:field_width()
  assert(type(format) == "string")
  assert(#format > 0)
  assert(#format < 64) -- some sanity check 

  local in_ctype = qconsts.qtypes[in_qtype].ctype
  local cst_in_as = in_ctype .. " *"
  local out_width = 32 -- TODO P3 Undo hard code
  local out_qtype = "SC"
  local out_buf 
  local cst_out_buf
  local chunk_idx = 0
  local first_call = true
  local function gen(chunk_num)
    assert(chunk_num == chunk_idx)
    if ( first_call ) then 
      out_buf = cmem.new(qconsts.chunk_size * out_width)
      cst_out_buf = get_ptr(out_buf, "char  * ")
      first_call = false
    end
    local len, base_data = inv:chunk(chunk_idx)
    if ( len > 0 ) then 
      local in_ptr = get_ptr(base_data, cst_in_a)
      local status = qc["TM_to_SC"](in_ptr, len, format,
        cst_out_buf, out_width)
      assert(status == 0)
      chunk_idx = chunk_idx + 1
    end
    return len, out_buf
  end
  local outv = lVector({qtype = out_qtype, width =  out_width, gen = gen, has_nulls = false})
  return outv
end
return require('Q/q_export').export('TM_to_SC', TM_to_SC)
