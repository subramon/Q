local ffi = require 'ffi'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local promote = require 'Q/UTILS/lua/promote'
local qconsts = require 'Q/UTILS/lua/qconsts'
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
  f2,
  optargs
  )
  local subs = {}; 
  assert(type(f1) == "lVector"); assert(not f1:has_nulls())
  assert(type(f2) == "lVector"); assert(not f2:has_nulls())
  local f1_qtype = f1:qtype();   
  local f2_qtype = f2:qtype();   
  assert(is_basetype[f1_qtype]); assert(is_basetype[f2_qtype]); 

  local f3_qtype = promote(f1_qtype, f2_qtype)
  if ( optargs ) then
    assert(type(optargs) == "table")
    f3_qtype = optargs.f3_qtype or f3_qtype
  end
  assert(is_basetype[f3_qtype])
  

  subs.fn = "vvdiv_" .. f1_qtype .. "_" .. f2_qtype .. "_" .. f3_qtype 
  subs.fn_ispc = subs.fn .. "_ispc"

  subs.f1_ctype = qconsts.qtypes[f1_qtype].ctype
  subs.f1_cast_as = subs.f1_ctype .. "*"

  subs.f2_ctype = qconsts.qtypes[f2_qtype].ctype
  subs.f2_cast_as = subs.f2_ctype .. "*"

  subs.f3_qtype = f3_qtype
  subs.f3_ctype = qconsts.qtypes[f3_qtype].ctype
  subs.f3_cast_as = subs.f3_ctype .. "*"

  subs.cargs = nil
  subs.cst_cargs = ffi.NULL

  subs.code = " c = a / b; "
  subs.tmpl   = "OPERATORS/F1F2OPF3/lua/f1f2opf3_sclr.tmpl"
  subs.incdir = "OPERATORS/F1F2OPF3/gen_inc/"
  subs.srcdir = "OPERATORS/F1F2OPF3/gen_src/"
  subs.incs = { "OPERATORS/F1F2OPF3/gen_inc/", "UTILS/inc/"}
  subs.libs = { "-lgomp", "-lm", } 
  -- for ISPC
  subs.f1_ctype_ispc = qconsts.qtypes[f1_qtype].ispctype
  subs.f2_ctype_ispc = qconsts.qtypes[f2_qtype].ispctype
  subs.f3_ctype_ispc = qconsts.qtypes[f3_qtype].ispctype
  subs.tmpl_ispc   = "OPERATORS/F1F2OPF3/lua/f1f2opf3_ispc.tmpl"
  return subs
end
