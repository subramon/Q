local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local Scalar  = require 'libsclr'
local is_in   = require 'Q/UTILS/lua/is_in'

return function (
  f1,
  s1,
  optargs
  )
  local subs = {}; 
  assert(type(f1) == "lVector"); assert(not f1:has_nulls())

  subs.f1_qtype = f1:qtype()
  assert(is_in(subs.f1_qtype, { 
    "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", "F4", "F8" }))
 
  assert(type(s1) == "Scalar")
  subs.s1_qtype = s1:qtype()
  assert(is_in(subs.s1_qtype, { 
    "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", "F4", "F8" }))
  subs.s1_ctype = cutils.str_qtype_to_str_ctype(subs.s1_qtype)
  subs.cast_s1_as  = subs.s1_ctype .. " *"
  assert(type(s1) == "Scalar") 

  subs.f1_ctype = cutils.str_qtype_to_str_ctype(subs.f1_qtype)
  subs.cast_f1_as  = subs.f1_ctype .. " *"

  subs.f2_qtype = optargs.f2_qtype or "BL"
  assert(( subs.f2_qtype == "B1" ) or ( subs.f2_qtype == "BL" ))
  assert(subs.f2_qtype == "BL") -- TODO P4 Restriction For now 

  subs.f2_ctype = cutils.str_qtype_to_str_ctype(subs.f2_qtype)
  subs.cast_f2_as  = subs.f2_ctype .. " *"

  subs.f2_width = cutils.get_width_qtype(subs.f2_qtype)
  subs.max_num_in_chunk = f1:max_num_in_chunk()
  subs.f2_buf_sz = subs.max_num_in_chunk * subs.f2_width

  subs.fn = 'vsgt'
    .. "_" .. subs.f1_qtype 
    .. "_" .. subs.s1_qtype 
    .. "_" .. subs.f2_qtype 
  subs.fn_ispc = subs.fn .. "_ispc"

  subs.omp_chunk_size = 1024 -- TODO experiment with this 

  if ( s1 ) then 
    subs.ptr_to_sclr = ffi.cast(subs.cast_s1_as, s1:to_data())
  else
    subs.cast_cargs = ffi.NULL
  end

  subs.code = 'c = a > b;'
  subs.tmpl        = "OPERATORS/F1S1OPF2/lua/f1s1opf2_sclr.tmpl"
  subs.srcdir      = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1S1OPF2/gen_inc/", "UTILS/inc/" }
  subs.libs        = { "-lgomp", "-lm" }
--[[ TODO 
  -- for ISPC
  subs.code_ispc = "c = a == b;"
  subs.f1_ctype_ispc = qconsts.qtypes[f1_qtype].ispctype
  subs.s1_ctype_ispc = qconsts.qtypes[s1_qtype].ispctype
  subs.f2_ctype_ispc = qconsts.qtypes[f2_qtype].ispctype
  subs.tmpl_ispc   = "OPERATORS/F1S1OPF2/lua/f1s1opf2_ispc.tmpl"
  --]]
  return subs
end
