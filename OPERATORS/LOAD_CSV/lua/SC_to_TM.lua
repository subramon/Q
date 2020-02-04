local qc          = require 'Q/UTILS/lua/q_core'
local ffi         = require 'ffi'
local cmem        = require 'libcmem'
local cVector     = require 'libvctr'
local qconsts     = require 'Q/UTILS/lua/q_consts'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local lVector     = require 'Q/RUNTIME/VCTR/lua/lVector'
local function SC_to_TM(
  invec, 
  format,
  optargs
  )
  assert(type(invec) == "lVector")
  assert(invec:fldtype() == "SC")
  assert(invec:has_nulls() == false)
  local in_width = invec:field_width()
  assert(type(format) == "string")
  assert(#format > 0)

  -- START: Dynamic compilation
  local func_name = "SC_to_TM"
  if ( not qc[func_name] ) then 
    local root = assert(qconsts.Q_SRC_ROOT)
    local subs = {}
    subs.fn = func_name
    subs.dotc = root .. "/OPERATORS/LOAD_CSV/src/SC_to_TM.c"
    subs.doth = root .. "/OPERATORS/LOAD_CSV/inc/SC_to_TM.h"
    qc.q_add(subs); print("Dynamic compilation kicking in... ")
  end 
  local cfunc = assert(qc[func_name], "Symbol not available" .. func_name)
  -- STOP : Dynamic compilation
  
  local chunk_size = cVector.chunk_size()
  local out_qtype = "TM"
  local out_ctype = qconsts.qtypes[out_qtype].ctype
  local out_width = qconsts.qtypes[out_qtype].width
  local buf  = assert(cmem.new(0))
  local l_chunk_num = 0
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    if ( not buf:is_data() ) then 
      buf = assert(cmem.new(
        { size = chunk_size * out_width, qtype = out_qtype}))
      buf:stealable(true)
    end
    local cst_buf = ffi.cast(out_ctype .. "  *", get_ptr(buf))
    local len, base_data = invec:get_chunk(l_chunk_num)
    if ( len > 0 ) then 
      local ptr_to_chars = ffi.cast("char *", get_ptr(base_data))
      local status = cfunc(ptr_to_chars, in_width, len, format, cst_buf)
      assert(status == 0)
      l_chunk_num = l_chunk_num + 1
    end
    return len, buf
  end
  local outv = lVector({qtype = out_qtype, gen = gen, has_nulls = false})
  return outv
end
return require('Q/q_export').export('SC_to_TM', SC_to_TM)
