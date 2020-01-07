local Q           = require 'Q/q_export'
local qc          = require 'Q/UTILS/lua/q_core'
local ffi         = require 'ffi'
local cmem        = require 'libcmem'
local qconsts     = require 'Q/UTILS/lua/q_consts'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local lVector     = require 'Q/RUNTIME/VCTR/lua/lVector'

local function TM_to_I2(
  invec, 
  tm_fld
  )
  assert(type(invec) == "lVector")
  assert(invec:has_nulls() == false)
  local in_width = invec:field_width()
  local in_qtype = assert(invec:fldtype())
  assert(in_qtype == "TM")
  local spfn = require 'Q/OPERATORS/LOAD_CSV/lua/TM_to_I2_specialize'
  local status, subs = pcall(spfn, tm_fld)
  assert(status)
  local func_name = assert(subs.fn)
  -- START: Dynamic compilation
  if ( not qc[func_name] ) then
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end
  -- STOP: Dynamic compilation
  assert(qc[func_name], "Function not found " .. func_name)


  local in_ctype = qconsts.qtypes[in_qtype].ctype
  local cst_in_as = in_ctype .. " *"

  local out_qtype = "I2" -- hard coded 
  local out_ctype = qconsts.qtypes[out_qtype].ctype
  local cst_out_as = out_ctype .. " *"
  local out_width = qconsts.qtypes[out_qtype].width

  local out_buf 
  local cst_out_buf
  local chunk_idx = 0
  local first_call = true
  local function gen(chunk_num)
    assert(chunk_num == chunk_idx)
    if ( first_call ) then 
      out_buf = cmem.new(qconsts.chunk_size * out_width)
      cst_out_buf = ffi.cast(cst_out_as, get_ptr(out_buf))
      first_call = false
    end
    local len, base_data = invec:chunk(chunk_idx)
    if ( len > 0 ) then 
      local in_ptr = ffi.cast(cst_in_as, get_ptr(base_data))
      local status = qc[func_name](in_ptr, len, cst_out_buf)
      assert(status == 0)
      chunk_idx = chunk_idx + 1
    end
    return len, out_buf
  end
  local outv = lVector({qtype = out_qtype, gen = gen, has_nulls = false})
  return outv
end
return require('Q/q_export').export('TM_to_I2', TM_to_I2)
