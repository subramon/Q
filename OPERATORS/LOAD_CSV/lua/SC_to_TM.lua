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
      has_nulls = true 
      subs.fn = "nn_SC_to_TM1"
      subs.dotc = "OPERATORS/LOAD_CSV/src/nn_SC_to_TM1.c"
      subs.doth = "OPERATORS/LOAD_CSV/inc/nn_SC_to_TM1.h"
    else
      subs.fn = "SC_to_TM1"
      subs.dotc = "OPERATORS/LOAD_CSV/src/SC_to_TM1.c"
      subs.doth = "OPERATORS/LOAD_CSV/inc/SC_to_TM1.h"
    end
  else
    error("bad output qtype")
  end
  subs.incs = { "OPERATORS/LOAD_CSV/inc/", "UTILS/inc/" }

  qc.q_add(subs)
  
  local out_ctype = cutils.str_qtype_to_str_ctype(subs.out_qtype)
  local out_width = cutils.get_width_qtype(subs.out_qtype)
  local bufsz = subs.max_num_in_chunk * out_width
  local nn_bufsz = subs.max_num_in_chunk * 1
  local l_chunk_num = 0
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    -- create space for output 
    local buf = assert(cmem.new( { name = "SC_to_TM" .. tostring(chunk_num),
      size = bufsz, qtype = subs.out_qtype}))
    buf:stealable(true)
    local cst_buf = get_ptr(buf, out_ctype .. "  *")

    local nn_buf
    if ( has_nulls ) then 
      nn_buf = assert(cmem.new(
        { name = "nn_SC_to_TM" .. tostring(chunk_num),
        size = nn_bufsz, qtype = "BL"}))
      nn_buf:stealable(true)
    end
    local cst_nn_buf = get_ptr(nn_buf, "bool *")
    -- get input
    local len, base_data, nn_data  = invec:get_chunk(l_chunk_num)
    if ( len == 0 ) then 
      buf:delete()
      nn_buf:delete()
      -- print("A SC_to_TM killing Vector " .. (invec:name() or "anon"))
      invec:kill()
      return 0, nil 
    end 
    assert(type(base_data) == "CMEM")
    local base_ptr = get_ptr(base_data, "char *")
    assert(base_ptr ~= ffi.NULL)
    local nn_ptr
    if ( has_nulls ) then 
      assert(nn_data)
      nn_ptr = get_ptr(nn_data, "bool *")
      assert(nn_ptr ~= ffi.NULL)
    end
    local start_time = cutils.rdtsc()
    local status
    if ( has_nulls ) then 
      status = qc[subs.fn](base_ptr, nn_ptr, in_width, len, format, 
      cst_buf, cst_nn_buf)
    else
      status = qc[subs.fn](base_ptr, in_width, len, format, cst_buf)
    end
    record_time(start_time, "SC_to_TM")
    assert(status == 0)
    invec:unget_chunk(l_chunk_num)
    l_chunk_num = l_chunk_num + 1
    if ( len < subs.max_num_in_chunk ) then 
      -- print("B SC_to_TM killing Vector " .. (invec:name() or "anon"))
      invec:kill()
    end
    if ( has_nulls ) then 
      return len, buf, nn_buf
    else
      return len, buf
    end
  end
  --===============================================
  local args = {qtype = subs.out_qtype, gen = gen, has_nulls = has_nulls}
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
