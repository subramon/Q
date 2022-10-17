local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local lVector = require 'Q/RUNTIME/VCTRS/lua/lVector'
local promote = require 'Q/UTILS/lua/promote'
local is_in   = require 'Q/UTILS/lua/is_in'

return function (
  f1, 
  f2,
  optargs
  )
  local subs = {}; 
  assert(type(f1) == "lVector"); assert(not f1:has_nulls())
  assert(type(f2) == "lVector"); assert(not f2:has_nulls())
  local f1_qtype = f1:qtype();   
  local f2_qtype = f2:qtype();   
  assert(is_in(f1_qtype, { "I1", "I2", "I4", "I8", "F4", "F8", }))
  assert(is_in(f2_qtype, { "I1", "I2", "I4", "I8", "F4", "F8", }))
  subs.max_num_in_chunk = f1:max_num_in_chunk()
  assert(f1:max_num_in_chunk() == f2:max_num_in_chunk())

  local f3_qtype = promote(f1_qtype, f2_qtype)
  if ( optargs ) then
    assert(type(optargs) == "table")
    if ( optargs.f3_qtype ) then
      f3_qtype = optargs.f3_qtype
    end
  end
  assert(is_in(f3_qtype, { "I1", "I2", "I4", "I8", "F4", "F8", }))

  subs.fn = "vvsub_" .. f1_qtype .. "_" .. f2_qtype .. "_" .. f3_qtype 
  subs.fn_ispc = subs.fn .. "_ispc"

  subs.f1_ctype = cutils.str_qtype_to_str_ctype(f1_qtype)
  subs.f1_cast_as = subs.f1_ctype .. "*"

  subs.f2_ctype = cutils.str_qtype_to_str_ctype(f2_qtype)
  subs.f2_cast_as = subs.f2_ctype .. "*"

  subs.f3_qtype = f3_qtype
  subs.f3_ctype = cutils.str_qtype_to_str_ctype(f3_qtype)
  subs.f3_cast_as = subs.f3_ctype .. "*"

  subs.f3_width = cutils.get_width_qtype(f3_qtype)

  subs.cargs = nil
  subs.cst_cargs = ffi.NULL

  subs.code = "c = a - b; "
  subs.tmpl   = "OPERATORS/F1F2OPF3/lua/f1f2opf3_sclr.tmpl"
  subs.incdir = "OPERATORS/F1F2OPF3/gen_inc/"
  subs.srcdir = "OPERATORS/F1F2OPF3/gen_src/"
  subs.incs = { "OPERATORS/F1F2OPF3/gen_inc/", "UTILS/inc/"}
  subs.libs = { "-lgomp", "-lm", } 
  -- for ISPC
  subs.f1_ctype_ispc = cutils.str_qtype_to_str_ispctype(f1_qtype)
  subs.f2_ctype_ispc = cutils.str_qtype_to_str_ispctype(f2_qtype)
  subs.f3_ctype_ispc = cutils.str_qtype_to_str_ispctype(f3_qtype)
  subs.tmpl_ispc   = "OPERATORS/F1F2OPF3/lua/f1f2opf3_ispc.tmpl"
  return subs
end
