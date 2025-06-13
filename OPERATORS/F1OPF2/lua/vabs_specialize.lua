-- logical negation
local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local is_in   = require 'RSUTILS/lua/is_in'

return function (
  f1,
  optargs
  )
  local subs = {}; 
  assert(type(f1) == "lVector"); assert(not f1:has_nulls())

  -- consider allowing UI* as well 
 
  subs.f1_qtype = f1:qtype()
  subs.f1_ctype = cutils.str_qtype_to_str_ctype(subs.f1_qtype)
  subs.cast_f1_as  = subs.f1_ctype .. " *"

  assert(is_in(subs.f1_qtype,{ "I1", "I2", "I4", "I8", "F4", "F8"}))

  subs.f2_qtype = subs.f1_qtype
  subs.f2_ctype = cutils.str_qtype_to_str_ctype(subs.f2_qtype)
  subs.cast_f2_as  = subs.f2_ctype .. " *"

  subs.f2_width = cutils.get_width_qtype(subs.f2_qtype)
  subs.max_num_in_chunk = f1:max_num_in_chunk()
  subs.f2_buf_sz = subs.max_num_in_chunk * subs.f2_width

  subs.fn = 'vabs'
    .. "_" .. subs.f1_qtype 
    .. "_" .. subs.f2_qtype 
  subs.fn_ispc = subs.fn .. "_ispc"

  subs.chunk_size = 1024 -- TODO experiment with this 


  if ( subs.f1_qtype == "F4" )  then
    subs.code = "c = fabsf(a); "
  elseif ( subs.f1_qtype == "F8" )  then
    subs.code = "c = fabs(a); "
  elseif ( subs.f1_qtype == "I1" )  then
    subs.code = "c = abs(a); "
  elseif ( subs.f1_qtype == "I2" )  then
    subs.code = "c = abs(a); "
  elseif ( subs.f1_qtype == "I4" )  then
    subs.code = "c = abs(a); "
  elseif ( subs.f1_qtype == "I8" )  then
    subs.code = "c = llabs(a); "
  else
    error("Bad type for vabs() = " .. subs.f1_qtype)
  end

  subs.tmpl        = "OPERATORS/F1OPF2/lua/f1opf2.tmpl"
  subs.srcdir      = "OPERATORS/F1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1OPF2/gen_inc/"
  local rsutils_src_root = os.getenv("RSUTILS_SRC_ROOT")
  assert(cutils.isdir(rsutils_src_root))
  subs.incs        = { "OPERATORS/F1OPF2/gen_inc/", 
    rsutils_src_root .. "/inc/" }
  subs.libs        = { "-lgomp", "-lm" }
  return subs
end
