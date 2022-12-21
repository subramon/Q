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
  assert(type(optargs) == "table")
  assert(type(f1) == "lVector"); assert(not f1:has_nulls())

  subs.f1_qtype = f1:qtype()
  assert(is_in(subs.f1_qtype, { "I1", "I2", "I4", "I8", }))
 
  assert(type(s1) == "Scalar")
  assert(is_in(s1:qtype(), { "I1", "I2", "I4", "I8", }))
  -- convert to I1 type 
  local snum = s1:to_num()
  s1 = Scalar.new(snum, "I1")
  subs.s1_qtype = "I1"
  subs.s1_ctype = cutils.str_qtype_to_str_ctype(subs.s1_qtype)
  subs.cast_s1_as  = subs.s1_ctype .. " *"
  assert(type(s1) == "Scalar") 

  subs.f1_ctype = "u" .. cutils.str_qtype_to_str_ctype(subs.f1_qtype)
  subs.cast_f1_as  = subs.f1_ctype .. " *"

  assert( (snum >= 0 ) and ( snum < 8*ffi.sizeof(subs.f1_ctype)) )

  subs.f2_qtype = subs.f1_qtype

  subs.f2_ctype = "u" .. cutils.str_qtype_to_str_ctype(subs.f2_qtype)
  subs.cast_f2_as  = subs.f2_ctype .. " *"

  subs.f2_width = cutils.get_width_qtype(subs.f2_qtype)
  subs.max_num_in_chunk = f1:max_num_in_chunk()
  subs.f2_buf_sz = subs.max_num_in_chunk * subs.f2_width

  subs.fn = optargs.__operator
    .. "_" .. subs.f1_qtype 
    .. "_" .. subs.f2_qtype 
  subs.fn_ispc = subs.fn .. "_ispc"

  subs.chunk_size = 1024 -- TODO experiment with this 

  subs.ptr_to_sclr = ffi.cast(subs.cast_s1_as, s1:to_data())

  subs.code = 'c = a >> b;'
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
