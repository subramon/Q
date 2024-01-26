local qc          = require 'Q/UTILS/lua/qcore'
local ffi         = require 'ffi'
local cmem        = require 'libcmem'
local cutils      = require 'libcutils'
local qcfg        = require 'Q/UTILS/lua/qcfg'
local get_ptr     = require 'Q/UTILS/lua/get_ptr'
local record_time = require 'Q/UTILS/lua/record_time'
local lVector     = require 'Q/RUNTIME/VCTRS/lua/lVector'


local function TM_to_SC(
  inv, 
  format,
  optargs
  )
  assert(type(inv) == "lVector")
  local in_qtype = "TM"
  assert(inv:qtype() == in_qtype)
  assert(inv:has_nulls() == false)
  local in_width = inv:width()
  assert(type(format) == "string")
  assert(#format > 0)
  assert(#format < 64) -- some sanity check 

  local subs = {}
  subs.fn = "TM_to_SC"
  subs.dotc = "OPERATORS/LOAD_CSV/src/TM_to_SC.c"
  subs.doth = "OPERATORS/LOAD_CSV/inc/TM_to_SC.h"
  subs.incs = { "OPERATORS/LOAD_CSV/inc/", "UTILS/inc/" }
  -- subs.srcs = {}
  qc.q_add(subs)

  local max_num_in_chunk = inv:max_num_in_chunk()
  local in_ctype = cutils.str_qtype_to_str_ctype(in_qtype)
  local cst_in_as = in_ctype .. " *"
  local out_width = 32 -- TODO P3 Undo hard code
  local out_qtype = "SC"
  local chunk_idx = 0
  local function gen(chunk_num)
    assert(chunk_num == chunk_idx)
    local out_buf = cmem.new(max_num_in_chunk* out_width)
    out_buf:stealable(true)
    local cst_out_buf = get_ptr(out_buf, "char  * ")
    local len, base_data = inv:get_chunk(chunk_idx)
    if ( len == 0 ) then 
      out_buf:delete()
      return 0
    end 
    local in_ptr = get_ptr(base_data, cst_in_as)
    assert(in_ptr ~= ffi.NULL)
    local start_time = cutils.rdtsc()
    local status = qc["TM_to_SC"](in_ptr, len, format,
      cst_out_buf, out_width)
    record_time(start_time, "TM_to_SC")
    assert(status == 0)
    inv:unget_chunk(chunk_idx)
    if ( len < max_num_in_chunk ) then return len, out_buf end 
    chunk_idx = chunk_idx + 1
    return len, out_buf
  end
  --===============================================
  local args = {
    qtype = out_qtype, 
    width =  out_width, 
    gen = gen, 
    has_nulls = false}
  if ( optargs ) then 
    assert(k ~= "qtype")
    assert(k ~= "gen")
    assert(k ~= "width")
    assert(type(optargs) == "table")
    for k, v in pairs(optargs) do 
      args[k] = v 
    end
  end
  --===============================================
  return lVector(args)
end
return require('Q/q_export').export('TM_to_SC', TM_to_SC)
