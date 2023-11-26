local ffi    = require 'ffi'
local cutils = require 'libcutils'
local Scalar = require 'libsclr'
local is_in  = require 'Q/UTILS/lua/is_in'

return function (
  f1,
  s1,
  optargs
  )
  local subs = {}; 
  assert(type(f1) == "lVector"); assert(not f1:has_nulls())

  assert(type(s1) == "Scalar")
  local s1_qtype = s1:qtype()

  local f1_qtype = f1:qtype()
  assert(is_in(f1_qtype, { "I1", "I2", "I4", "I8" }))
 
  local fn = "vsand" .. "_" .. f1_qtype
  if ( s1_qtype ) then fn = fn .. "_" .. s1_qtype end 
  subs.fn = fn 

  subs.f1_qtype   = f1_qtype
  subs.f1_ctype   = cutils.str_qtype_to_str_ctype(f1_qtype)
  subs.cast_f1_as  = subs.f1_ctype .. " *"
  subs.f1_width   = cutils.get_width_qtype(f1_qtype)

  assert(s1_qtype == f1_qtype) -- TODO P4 relax 

  subs.f2_qtype  = subs.f1_qtype
  subs.f2_ctype  = subs.f1_ctype
  subs.cast_f2_as = subs.cast_f1_as
  subs.f2_width   = subs.f1_width
  subs.f2_buf_sz  = subs.f1_width * f1:max_num_in_chunk()

  subs.cargs      = s1:to_data()
  subs.s1_qtype   = s1_qtype
  subs.s1_ctype   = cutils.str_qtype_to_str_ctype(s1_qtype)
  subs.cast_s1_as = subs.s1_ctype .. " *"

  subs.code = "c = a & b; "
  subs.tmpl        = "OPERATORS/F1S1OPF2/lua/f1s1opf2_sclr.tmpl"
  subs.srcdir      = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1S1OPF2/gen_inc/", "UTILS/inc/" }
  subs.libs        = { "-lgomp", "-lm" }
  --[[ for ISPC
  subs.fn = XXXX:
  subs.code_ispc = "c = a & b; "
  subs.f1_ctype_ispc = qconsts.qtypes[f1_qtype].ispctype
  subs.s1_ctype_ispc = qconsts.qtypes[s1_qtype].ispctype
  subs.f2_ctype_ispc = qconsts.qtypes[f2_qtype].ispctype
  subs.tmpl_ispc   = "OPERATORS/F1S1OPF2/lua/f1s1opf2_ispc.tmpl"
  --]]
  return subs
end
