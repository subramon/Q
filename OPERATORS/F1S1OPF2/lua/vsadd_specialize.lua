local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local Scalar  = require 'libsclr'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

return function (
  f1,
  s1,
  optargs
  )
  local subs = {}; 
  assert(type(f1) == "lVector"); 

  assert(type(s1) == "Scalar")
  local s1_qtype = s1:qtype()

  local f1_qtype = f1:qtype()
  assert(is_base_qtype(f1_qtype))
 

  subs.f1_qtype   = f1_qtype
  subs.f1_ctype   = cutils.str_qtype_to_str_ctype(f1_qtype)
  subs.cast_f1_as  = subs.f1_ctype .. " *"

  -- Forcing output type  == input type
  -- Use additional call to vconvert() if you want to change outut type 
  subs.f2_qtype    = f1_qtype
  subs.f2_ctype    = cutils.str_qtype_to_str_ctype(f1_qtype)
  subs.cast_f2_as  = subs.f1_ctype .. " *"
  subs.f2_width    = cutils.get_width_qtype(f1_qtype)
  subs.f2_max_num_in_chunk   = f1:max_num_in_chunk() 
  subs.f2_buf_sz   = subs.f2_max_num_in_chunk * subs.f2_width

  subs.cargs       = s1:to_data()
  subs.s1_qtype    = subs.f1_qtype
  subs.s1_ctype    = subs.f1_ctype
  subs.cast_s1_as  = subs.f1_ctype .. " *"
  subs.cast_cargs  = ffi.cast(subs.s1_ctype .. " *", subs.cargs)

  subs.omp_chunk_size = 1024 -- TODO experiment with this

  if ( f1:has_nulls() ) then 
    subs.has_nulls = true 
    subs.fn = "nn_BL_vsadd" .. "_" .. f1_qtype
    assert(f1:nn_qtype() == "BL") -- TODO B1 not implememnted
    subs.tmpl        = "OPERATORS/F1S1OPF2/lua/nn_BL_f1s1opf2_sclr.tmpl"
    subs.nn_f2_qtype = "BL"; -- B1 not supported yet 
    subs.nn_f2_buf_sz   = subs.f2_max_num_in_chunk 
    subs.code = "    out[i] = in[i] + b; "; 
    subs.nn_code = "    out[i] = 0; "
  else
    subs.fn = "vsadd" .. "_" .. f1_qtype
    subs.code = "c = a + b; "
    subs.has_nulls = false
    subs.tmpl        = "OPERATORS/F1S1OPF2/lua/f1s1opf2_sclr.tmpl"
  end
  subs.srcdir      = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1S1OPF2/gen_inc/", "UTILS/inc/" }
  subs.libs        = { "-lgomp", "-lm" }
  --[[ for ISPC
  subs.fn_ispc = fn .. "_ispc"
  subs.code_ispc = "c = a + b; "
  subs.f1_ctype_ispc = qconsts.qtypes[f1_qtype].ispctype
  subs.s1_ctype_ispc = qconsts.qtypes[s1_qtype].ispctype
  subs.f2_ctype_ispc = qconsts.qtypes[f2_qtype].ispctype
  subs.tmpl_ispc   = "OPERATORS/F1S1OPF2/lua/f1s1opf2_ispc.tmpl"
  --]]
  return subs
end
