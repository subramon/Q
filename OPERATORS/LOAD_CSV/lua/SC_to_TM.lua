local qc          = require 'Q/UTILS/lua/qcore'
local ffi         = require 'ffi'
local cmem        = require 'libcmem'
local cutils      = require 'libcutils'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local lVector     = require 'Q/RUNTIME/VCTRS/lua/lVector'
local qcfg        = require 'Q/UTILS/lua/qcfg'

local function SC_to_TM(
  invec, 
  format,
  optargs
  )
  assert(type(invec) == "lVector")
  assert(invec:qtype() == "SC")
  local in_width = invec:width()
  assert(type(format) == "string")
  assert(#format > 0)

  local subs = {}
  subs.out_qtype = "TM" -- default assumption
  subs.max_num_in_chunk = invec:max_num_in_chunk()
  if ( optargs ) then
    assert(type(optargs) == "table")
    if ( optargs.out_qtype ) then
      assert(type(optargs.out_qtype) == "string")
      subs.out_qtype = optargs.out_qtype
    end
  end
  local has_nulls = false
  if ( subs.out_qtype == "TM" ) then 
    subs.fn = "SC_to_TM"
    subs.dotc = "OPERATORS/LOAD_CSV/src/SC_to_TM.c"
    subs.doth = "OPERATORS/LOAD_CSV/inc/SC_to_TM.h"
  elseif ( subs.out_qtype == "TM1" ) then 
    if ( invec:has_nulls() ) then 
      subs.fn = "SC_to_TM1"
      subs.dotc = "OPERATORS/LOAD_CSV/src/SC_to_TM1.c"
      subs.doth = "OPERATORS/LOAD_CSV/inc/SC_to_TM1.h"
      has_nulls = true 
    else
      subs.fn = "nn_SC_to_TM1"
      subs.dotc = "OPERATORS/LOAD_CSV/src/nn_SC_to_TM1.c"
      subs.doth = "OPERATORS/LOAD_CSV/inc/nn_SC_to_TM1.h"
    end
  else
    error("bad output qtype")
  end
  subs.incs = { "OPERATORS/LOAD_CSV/inc/", "UTILS/inc/" }

  qc.q_add(subs)
  
  local out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  local out_width = cutils.get_width_qtype(subs.out_qtype)
  local l_chunk_num = 0
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    local buf = assert(cmem.new(
        { size = subs.max_num_in_chunk * out_width, qtype = subs.out_qtype}))
    buf:stealable(true)
    local cst_buf = get_ptr(buf, out_ctype .. "  *")
    local len, base_data, nn_data  = invec:get_chunk(l_chunk_num)
    if ( len == 0 ) then return 0, nil end 
    assert(type(base_data) == "CMEM")
    local base_ptr = get_ptr(base_data, "char *")
    assert(base_ptr ~= ffi.NULL)
    local nn_ptr = get_ptr(nn_data, "int8_t *")
    assert(nn_ptr ~= ffi.NULL)
    local start_time = cutils.rdtsc()
    local status
    if ( has_nulls ) then 
      status = qc[subs.fn](base_ptr, nn_ptr, in_width, len, format, cst_buf)
    else
      status = qc[subs.fn](base_ptr, in_width, len, format, cst_buf)
    end
    record_time(start_time, "load_csv_fast")
    assert(status == 0)
    invec:unget_chunk(l_chunk_num)
    l_chunk_num = l_chunk_num + 1
    if ( has_nulls ) then 
      -- Note that nn for output is same as that for input 
      -- nn_data is NOT stealable, like buf. 
      -- I hope this doesn't cause problems! Fingers crossed :-)
      return len, buf, nn_data
    else
      return len, buf
    end
  end
  --===============================================
  local args = {qtype = subs.out_qtype, gen = gen, has_nulls = false}
  if ( optargs ) then 
    assert(type(optargs) == "table")
    for k, v in pairs(optargs) do 
      assert(k ~= "qtype")
      assert(k ~= "gen")
      args[k] = v 
    end
  end
  --===============================================
  return lVector(args)
end
return require('Q/q_export').export('SC_to_TM', SC_to_TM)
