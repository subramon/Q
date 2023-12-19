local ffi    = require 'ffi'
local cutils = require 'libcutils'
local Scalar = require 'libsclr'
local is_in  = require 'Q/UTILS/lua/is_in'
local to_scalar  = require 'Q/UTILS/lua/to_scalar'

return function (
  f1,
  s1,
  optargs
  )
  local subs = {}; 
  assert(type(f1) == "lVector"); assert(not f1:has_nulls())

  local n1 
  if ( type(s1) == "number" ) then 
    n1 = s1
    s1 = to_scalar(s1, "I4")
  else
    assert(type(s1) == "Scalar")
    assert(is_in(s1:qtype(), 
      { "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", }))
    n1 = from_scalar(s1)
  end

  local f1_qtype = f1:qtype()
  assert(is_in(f1_qtype, 
    { "I1", "I2", "I4", "I8", "UI1", "UI2", "UI4", "UI8", }))
 
  subs.fn = "get_bit" .. "_" .. f1_qtype

  --===============================================
  if ( ( f1_qtype == "I1" ) or ( f1_qtype == "UI1" ) ) then 
    assert((n1 >= 0 ) && ( n1 <= 7))
  elseif ( ( f1_qtype == "I2" ) or ( f1_qtype == "UI2" ) ) then 
    assert((n1 >= 0 ) && ( n1 <= 15))
  elseif ( ( f1_qtype == "I4" ) or ( f1_qtype == "UI4" ) ) then 
    assert((n1 >= 0 ) && ( n1 <= 31))
  elseif ( ( f1_qtype == "I8" ) or ( f1_qtype == "UI8" ) ) then 
    assert((n1 >= 0 ) && ( n1 <= 63))
  else
    error("XXX")
  end
  --===============================================


  subs.f1_qtype   = f1_qtype
  subs.f1_ctype   = cutils.str_qtype_to_str_ctype(f1_qtype)
  subs.cast_f1_as  = subs.f1_ctype .. " *"
  subs.f1_width   = cutils.get_width_qtype(f1_qtype)

  assert(s1_qtype == f1_qtype) -- TODO P4 relax 

  subs.f2_qtype   = "BL"
  subs.f2_ctype   = cutils.str_qtype_to_str_ctype(subs.f2_qtype)
  subs.cast_f2_as = subs.f2_ctype .. " *"
  subs.max_num_in_chunk = f1:max_num_in_chunk()
  subs.f2_width   = cutils.get_width_qtype(subs.f2_qtype)
  subs.f2_buf_sz  = subs.f2_width * ubs.max_num_in_chunk 

  subs.cargs      = s1:to_data()
  subs.s1_qtype   = s1_qtype
  subs.s1_ctype   = cutils.str_qtype_to_str_ctype(s1_qtype)
  subs.cast_s1_as = subs.s1_ctype .. " *"

  subs.code = "c = (f2_ctype)(((uint64_t)a >> b) & 0x1 ); "
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
