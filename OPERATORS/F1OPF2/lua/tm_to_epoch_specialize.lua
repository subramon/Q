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
  assert(subs.f1_qtype == "TM1") -- TODO P4 extend to TM 
  subs.f1_ctype = cutils.str_qtype_to_str_ctype(subs.f1_qtype)
  subs.cast_f1_as  = subs.f1_ctype .. " *"

  subs.f2_qtype = "UI4"
  subs.f2_ctype = cutils.str_qtype_to_str_ctype(subs.f2_qtype)
  subs.cast_f2_as  = subs.f2_ctype .. " *"

  subs.f2_width = cutils.get_width_qtype(subs.f2_qtype)
  subs.max_num_in_chunk = f1:max_num_in_chunk()
  subs.f2_buf_sz = subs.max_num_in_chunk * subs.f2_width

  subs.fn = 'tm_to_epoch'

  subs.chunk_size = 1024 -- for OpenMP  (experiment with this)

  subs.code = [[
  struct tm t1; memset(&t1, 0, sizeof(struct tm));
  t_assign(&t1, &a); 
  time_t tempt = tm2time(&t1); 
  // if ( tempt > INT_MAX ) { status = -1; }
  c = (uint32_t)tempt;
  ]]

  subs.tmpl        = "OPERATORS/F1OPF2/lua/f1opf2.tmpl"
  subs.srcdir      = "OPERATORS/F1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1OPF2/gen_inc/", "UTILS/inc/" }
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
