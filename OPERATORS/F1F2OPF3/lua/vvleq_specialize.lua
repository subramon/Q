local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local promote = require 'Q/UTILS/lua/promote'
local qcfg    = require 'Q/UTILS/lua/qcfg'
local get_max_num_in_chunk   = require 'Q/UTILS/lua/get_max_num_in_chunk'
local is_in   = require 'RSUTILS/lua/is_in'

return function (
  op,
  f1, 
  f2,
  optargs
  )
  local subs = {}; 
  assert(type(f1) == "lVector"); assert(not f1:has_nulls())
  assert(type(f2) == "lVector"); assert(not f2:has_nulls())
  local f1_qtype = f1:qtype();   
  local f2_qtype = f2:qtype();   
  assert(is_in(f1_qtype, { "BL", "I1", "I2", "I4", "I8", "F4", "F8", }))
  assert(is_in(f2_qtype, { "BL", "I1", "I2", "I4", "I8", "F4", "F8", }))
  local f1_max_num_in_chunk = assert(f1:max_num_in_chunk())
  local f2_max_num_in_chunk = assert(f2:max_num_in_chunk())
  assert( f1_max_num_in_chunk == f2_max_num_in_chunk)
  subs.max_num_in_chunk = f1_max_num_in_chunk
  -- WRONG! subs.max_num_in_chunk = get_max_num_in_chunk(optargs)
  local f3_qtype = "BL" 

  subs.f3_qtype = f3_qtype
  subs.f3_width = cutils.get_width_qtype(subs.f3_qtype)
  subs.bufsz = subs.max_num_in_chunk * subs.f3_width

  subs.fn = op .. f1_qtype .. "_" .. f2_qtype .. "_" .. f3_qtype 
  subs.fn_ispc = subs.fn .. "_ispc"

  subs.f1_ctype = cutils.str_qtype_to_str_ctype(f1_qtype)
  subs.f1_cast_as = subs.f1_ctype .. "*"

  subs.f2_ctype = cutils.str_qtype_to_str_ctype(f2_qtype)
  subs.f2_cast_as = subs.f2_ctype .. "*"

  subs.f3_qtype = f3_qtype
  subs.f3_ctype = cutils.str_qtype_to_str_ctype(f3_qtype)
  subs.f3_cast_as = subs.f3_ctype .. "*"

  subs.chunk_size = 1024 -- TODO P4 experiment with the value
  -- following is to stop gcc warning about passing bool to int8
  subs.f3_for_ispctype = subs.f3_ctype
  if ( subs.f3_ctype == "bool" ) then subs.f3_for_ispctype = "int8_t" end
  --===============
  subs.cargs = nil
  subs.cst_cargs = ffi.NULL

  subs.code = "c = a <= b;"
  subs.tmpl   = "OPERATORS/F1F2OPF3/lua/f1f2opf3_sclr.tmpl"
  subs.incdir = "OPERATORS/F1F2OPF3/gen_inc/"
  subs.srcdir = "OPERATORS/F1F2OPF3/gen_src/"
  subs.incs = { "OPERATORS/F1F2OPF3/gen_inc/", }
  subs.libs = { "-lgomp", "-lm", } 
  --=========================
  if ( qcfg.use_ispc ) then
    subs.f1_ctype_ispc = cutils.str_qtype_to_str_ispctype(f1_qtype)
    subs.f2_ctype_ispc = cutils.str_qtype_to_str_ispctype(f2_qtype)
    subs.f3_ctype_ispc = cutils.str_qtype_to_str_ispctype(f3_qtype)

    subs.tmpl_ispc   = "OPERATORS/F1F2OPF3/lua/f1f2opf3_ispc.tmpl"
    subs.comment_ispc = ""
  else
    subs.comment_ispc = "//"
  end
  return subs
end
