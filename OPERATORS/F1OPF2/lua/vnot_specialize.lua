-- logical negation
local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local Scalar  = require 'libsclr'
local is_in   = require 'RSUTILS/lua/is_in'

return function (
  f1,
  optargs
  )
  local subs = {}; 
  assert(type(f1) == "lVector"); assert(not f1:has_nulls())

  subs.f1_qtype = f1:qtype()
  assert(is_in(subs.f1_qtype,{ "BL", "B1", }))
 
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

  subs.fn = 'vseq'
    .. "_" .. subs.f1_qtype 
    .. "_" .. subs.f2_qtype 
  subs.fn_ispc = subs.fn .. "_ispc"

  subs.chunk_size = 1024 -- TODO experiment with this 


  subs.code = 'c = !a;'
  subs.tmpl        = "OPERATORS/F1OPF2/lua/f1opf2.tmpl"
  subs.srcdir      = "OPERATORS/F1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1OPF2/gen_inc/", "UTILS/inc/" }
  subs.libs        = { "-lgomp", "-lm" }
  return subs
end
