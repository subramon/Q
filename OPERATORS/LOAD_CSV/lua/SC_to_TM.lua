local qc          = require 'Q/UTILS/lua/qcore'
local ffi         = require 'ffi'
local cmem        = require 'libcmem'
local cutils      = require 'libcutils'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local lVector     = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qcfg        = require 'Q/UTILS/lua/qcfg'
local max_num_in_chunk = qcfg.max_num_in_chunk

local function SC_to_TM(
  invec, 
  format,
  optargs
  )
  assert(type(invec) == "lVector")
  assert(invec:qtype() == "SC")
  assert(invec:has_nulls() == false)
  local in_width = invec:width()
  assert(type(format) == "string")
  assert(#format > 0)

  local subs = {}
  subs.fn = "SC_to_TM"
  subs.dotc = "OPERATORS/LOAD_CSV/src/SC_to_TM.c"
  subs.doth = "OPERATORS/LOAD_CSV/inc/SC_to_TM.h"
  subs.incs = { "OPERATORS/LOAD_CSV/inc/", "UTILS/inc/" }
  -- subs.srcs = {}
  qc.q_add(subs)
  
  local out_qtype = "TM"
  local out_ctype = cutils.str_qtype_to_str_ctype(out_qtype)
  local out_width = cutils.get_width_qtype(out_qtype)
  local l_chunk_num = 0
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    local buf = assert(cmem.new(
        { size = max_num_in_chunk * out_width, qtype = out_qtype}))
      buf:stealable(true)
    local cst_buf = get_ptr(buf, out_ctype .. "  *")
    local len, base_data = invec:get_chunk(l_chunk_num)
    if ( len > 0 ) then 
      local base_ptr = get_ptr(base_data, "char *")
      assert(base_ptr ~= ffi.NULL)
      local start_time = cutils.rdtsc()
      local status = qc[subs.fn](base_ptr, in_width, len, format, 
        cst_buf)
      record_time(start_time, "load_csv_fast")
      assert(status == 0)
      l_chunk_num = l_chunk_num + 1
    end
    return len, buf
  end
  --===============================================
  local args = {qtype = out_qtype, gen = gen, has_nulls = false}
  if ( optargs ) then 
    assert(k ~= "qtype")
    assert(k ~= "gen")
    assert(type(optargs) == "table")
    for k, v in pairs(optargs) do 
      args[k] = v 
    end
  end
  --===============================================
  return lVector(args)
end
return require('Q/q_export').export('SC_to_TM', SC_to_TM)
