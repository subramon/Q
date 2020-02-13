local Q           = require 'Q/q_export'
local qc          = require 'Q/UTILS/lua/q_core'
local ffi         = require 'ffi'
local cmem        = require 'libcmem'
local cVector     = require 'libvctr'
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


  local chunk_size = cVector.chunk_size()
  local in_ctype = qconsts.qtypes[in_qtype].ctype
  local cst_in_as = in_ctype .. " *"

  local out_qtype = "I2" -- hard coded 
  local out_ctype = qconsts.qtypes[out_qtype].ctype
  local cst_out_as = out_ctype .. " *"
  local out_width = qconsts.qtypes[out_qtype].width

  local buf = cmem.new(0)
  local l_chunk_num = 0
  local first_call = true
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    if ( not buf:is_data() ) then 
      buf = cmem.new(chunk_size * out_width)
      buf:stealable(true)
    end
    local cst_buf = get_ptr(buf, cst_out_as)
    local len, base_data = invec:get_chunk(l_chunk_num)
    if ( len > 0 ) then 
      local in_ptr = get_ptr(base_data, cst_in_as)
      local status = qc[func_name](in_ptr, len, cst_buf)
      assert(status == 0)
      l_chunk_num = l_chunk_num + 1
    end
    return len, buf
  end
  local outv = lVector({qtype = out_qtype, gen = gen, has_nulls = false})
  return outv
end
return require('Q/q_export').export('TM_to_I2', TM_to_I2)
