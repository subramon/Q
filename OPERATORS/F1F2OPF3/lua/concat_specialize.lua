local ffi     = require 'ffi'
local cmem    = require 'libcmem'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local promote = require 'Q/UTILS/lua/promote'
local qconsts = require 'Q/UTILS/lua/q_consts'
local get_ptr = require 'Q/UTILS/lua/get_ptr'
local qc      = require 'Q/UTILS/lua/q_core'
local inttypes = { "I1", "I2", "I4", "I8" }
local is_inttype = {}
for _, inttype in ipairs(inttypes) do
  is_inttype[inttype] = true
end
qc.q_cdef("OPERATORS/F1F2OPF3/inc/f1f2opf3_concat.h")

return function (
  f1, 
  f2,
  optargs
  )
  local subs = {}; 
  assert(type(f1) == "lVector"); assert(not f1:has_nulls())
  assert(type(f2) == "lVector"); assert(not f2:has_nulls())
  local f1_qtype = f1:qtype();   assert(is_inttype[f1_qtype])
  local f2_qtype = f2:qtype();   assert(is_inttype[f2_qtype])

  assert(type(optargs) == "table")
  local f3_qtype = assert(optargs.f3_qtype)
  assert(is_inttype[f3_qtype])
  local shift_by = assert(optargs.shift_by )
  assert(type(shift_by) == "number")
  assert(shift_by >  0) 
  assert(shift_by <= 32)
  
  subs.fn = "vvconcat_" .. f1_qtype .. "_" .. f2_qtype .. "_" .. f3_qtype 
  subs.fn_ispc = subs.fn .. "_ispc"
  subs.f1_ctype = "u" .. qconsts.qtypes[f1_qtype].ctype
  subs.f2_ctype = "u" .. qconsts.qtypes[f2_qtype].ctype
  subs.f3_qtype = f3_qtype
  subs.f3_ctype = "u" .. qconsts.qtypes[f3_qtype].ctype

  -- allocate cargs
  local sz = ffi.sizeof("f1f2opf3_concat_t")
  subs.cargs = assert(cmem.new(sz))
  subs.cargs:zero()
  -- initialize cargs from scalar values 
  local cst_cargs = get_ptr(subs.cargs, "f1f2opf3_concat_t *")
  cst_cargs[0]["shift_by"] = shift_by
  subs.cst_cargs = cst_cargs


  subs.f1_cast_as = subs.f1_ctype .. "*"
  subs.f2_cast_as = subs.f2_ctype .. "*"
  subs.f3_cast_as = subs.f3_ctype .. "*"

  subs.tmpl   = "OPERATORS/F1F2OPF3/lua/concat_sclr.tmpl"
  subs.incdir = "OPERATORS/F1F2OPF3/gen_inc/"
  subs.srcdir = "OPERATORS/F1F2OPF3/gen_src/"
  subs.incs = { "OPERATORS/F1F2OPF3/gen_inc/", "UTILS/inc/", 
    "OPERATORS/F1F2OPF3/inc/" }

  subs.libs = { "-lgomp", "-lm" } 
  -- for ISPC
  subs.f1_ctype_ispc = "u" .. qconsts.qtypes[f1_qtype].ispctype
  subs.f2_ctype_ispc = "u" .. qconsts.qtypes[f2_qtype].ispctype
  subs.f3_ctype_ispc = "u" .. qconsts.qtypes[f3_qtype].ispctype
  subs.tmpl_ispc   = "OPERATORS/F1F2OPF3/lua/concat_ispc.tmpl"
  return subs
end
