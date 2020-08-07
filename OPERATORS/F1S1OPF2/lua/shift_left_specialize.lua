-- WARNING! If this line is in a .lua file, it is auto-generated
local Scalar  = require 'libsclr'
local qconsts       = require "Q/UTILS/lua/q_consts"
local basetypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
local is_basetype = {}
for _, basetype in ipairs(basetypes) do
  is_basetype[basetype] = true
end
local inttypes = { "I1", "I2", "I4", "I8" }
local is_inttype = {}
for _, inttype in ipairs(inttypes) do
  is_inttype[inttype] = true
end

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
  assert(is_basetype[f1_qtype]); 
 
  local fn = "shift_left" .. f1_qtype
  if ( s1_qtype ) then fn = fn .. "_" .. s1_qtype end 
  subs.fn = fn 
  subs.fn_ispc = fn .. "_ispc"

  subs.f1_qtype   = f1_qtype
  subs.f1_ctype   = assert(qconsts.qtypes[f1_qtype].ctype)
  subs.cst_f1_as  = subs.f1_ctype .. " *"

  local f2_qtype 
  if ( optargs ) then 
    assert(type(optargs) == "table") 
    if ( optargs.f2_qtype ) then 
      f2_qtype = optargs.f2_qtype 
      assert(is_basetype[f2_qtype]) -- not strong enough
    end
  end
  if ( not f2_qtype ) then 
    f2_qtype = f1_qtype

  end 
  -- TODO P2 chk_f2_qtype 
  local f2_qtype = "u" .. qconsts.qtypes[f2_qtype].ctype

  subs.f2_qtype = f2_qtype
  subs.f2_ctype = f2_ctype
  subs.cst_f2_as  = subs.f2_ctype .. " *"

  subs.f2_width = qconsts.qtypes[f2_qtype].width

  if ( s1_qtype ) then 
    subs.cargs     = s1:to_data()
    subs.cst_cargs = ffi.cast(subs.f1_ctype .. " *", subs.cargs)
  else
    subs.cst_cargs = ffi.NULL
  end

  subs.c_code_for_operator = "c = (uint64_t)a << (uint8_t)b"
  subs.tmpl        = "OPERATORS/F1S1OPF2/lua/f1s1opf2.tmpl"
  subs.srcdir      = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1S1OPF2/gen_inc/", "UTILS/inc/" }
  -- for ISPC
  subs.f1_ctype_ispc = qconsts.qtypes[f1_qtype].ispctype
  subs.f2_ctype_ispc = qconsts.qtypes[f2_qtype].ispctype
  subs.tmpl_ispc   = "OPERATORS/F1S1OPF2/lua/f1s1opf2_ispc.tmpl"
  return subs
end
