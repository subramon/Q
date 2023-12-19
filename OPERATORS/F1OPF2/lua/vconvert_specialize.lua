local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local Scalar  = require 'libsclr'
local is_in   = require 'Q/UTILS/lua/is_in'

return function (
  f1,
  optargs
  )
  local subs = {}; 
  assert(type(f1) == "lVector"); assert(not f1:has_nulls())

  subs.f1_qtype = f1:qtype()
  assert(is_in(subs.f1_qtype,{ "BL", "I1", "I2", "I4", "I8", "F2", "F4", "F8" }))
 
  subs.f1_ctype = cutils.str_qtype_to_str_ctype(subs.f1_qtype)
  subs.cast_f1_as  = subs.f1_ctype .. " *"

  assert(type(optargs) == "table")
  subs.f2_qtype = assert(optargs.newtype)

  subs.f2_ctype = cutils.str_qtype_to_str_ctype(subs.f2_qtype)
  subs.cast_f2_as  = subs.f2_ctype .. " *"

  subs.f2_width = cutils.get_width_qtype(subs.f2_qtype)
  subs.max_num_in_chunk = f1:max_num_in_chunk()
  subs.f2_buf_sz = subs.max_num_in_chunk * subs.f2_width

  subs.fn = 'convert'
    .. "_" .. subs.f1_qtype 
    .. "_" .. subs.f2_qtype 

  subs.chunk_size = 1024 -- for OpenMP  (experiment with this)

  subs.code = 'c = a;'; 
  if ( ( subs.f1_qtype == "F2" ) and ( subs.f2_qtype == "F4" ) ) then 
    subs.dotc = "OPERATORS/F1OPF2/src/convert_F2_F4.c"
    subs.doth = "OPERATORS/F1OPF2/inc/convert_F2_F4.h"
  elseif ( ( subs.f1_qtype == "F4" ) and ( subs.f2_qtype == "F2" ) ) then 
    subs.dotc = "OPERATORS/F1OPF2/src/convert_F4_F2.c"
    subs.doth = "OPERATORS/F1OPF2/inc/convert_F4_F2.h"
  else
    subs.tmpl        = "OPERATORS/F1OPF2/lua/f1opf2.tmpl"
  end
  subs.srcdir      = "OPERATORS/F1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1OPF2/gen_inc/", 
    "OPERATORS/F1OPF2/inc/", "UTILS/inc/" }
  subs.libs        = { "-lgomp", "-lm" }
--[[ TODO 
  -- for ISPC
  subs.fn_ispc = subs.fn .. "_ispc"
  subs.code_ispc = "c = a == b;"
  subs.f1_ctype_ispc = qconsts.qtypes[f1_qtype].ispctype
  subs.s1_ctype_ispc = qconsts.qtypes[s1_qtype].ispctype
  subs.f2_ctype_ispc = qconsts.qtypes[f2_qtype].ispctype
  subs.tmpl_ispc   = "OPERATORS/F1S1OPF2/lua/f1s1opf2_ispc.tmpl"
  --]]
  return subs
end
