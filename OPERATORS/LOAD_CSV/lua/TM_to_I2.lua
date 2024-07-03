local qc          = require 'Q/UTILS/lua/qcore'
local ffi         = require 'ffi'
local cmem        = require 'libcmem'
local cutils      = require 'libcutils'
local qcfg        = require 'Q/UTILS/lua/qcfg'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local lVector     = require 'Q/RUNTIME/VCTR/lua/lVector'

local function TM_to_I2(
  invec, 
  tm_fld,
  optargs
  )
  assert(type(invec) == "lVector")
  assert(invec:has_nulls() == false)
  local in_qtype = assert(invec:qtype())
  assert(in_qtype == "TM")
  local spfn = require 'Q/OPERATORS/LOAD_CSV/lua/TM_to_I2_specialize'
  local status, subs = pcall(spfn, tm_fld)
  assert(status)
  local func_name = assert(subs.fn)
  subs.incs = { "OPERATORS/LOAD_CSV/gen_inc/", "OPERATORS/LOAD_CSV/inc/", 
    "UTILS/inc/" }
  qc.q_add(subs)

 local max_num_in_chunk  = invec:max_num_in_chunk()
  local in_ctype = cutils.str_qtype_to_str_ctype(in_qtype)
  local cst_in_as = in_ctype .. " *"

  local out_qtype = "I2" -- hard coded 
  local out_ctype = cutils.str_qtype_to_str_ctype(out_qtype)
  local cst_out_as = out_ctype .. " *"
  local out_width = cutils.get_width_qtype(out_qtype)

  local l_chunk_num = 0
  local function gen(chunk_num)
    assert(chunk_num == l_chunk_num)
    local buf = cmem.new(max_num_in_chunk * out_width)
    assert(buf:is_data())
    buf:stealable(true)
    local cst_buf = get_ptr(buf, cst_out_as)
    local len, base_data = invec:get_chunk(l_chunk_num)
    if ( len == 0 ) then return 0, nil end 

    local in_ptr = get_ptr(base_data, cst_in_as)
    local status = qc[func_name](in_ptr, len, cst_buf)
    assert(status == 0)
    invec:unget_chunk(l_chunk_num)
    if ( len < max_num_in_chunk ) then return len, buf end 
    l_chunk_num = l_chunk_num + 1
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
return require('Q/q_export').export('TM_to_I2', TM_to_I2)
