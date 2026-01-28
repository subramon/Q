-- USED BY Q/UTILS/test/demo_dc.lua
local ffi     = require 'ffi'
local cutils  = require 'libcutils'
local cVector = require 'libvctr'
local lVector = require 'Q/RUNTIME/VCTR/lua/lVector'
local promote = require 'Q/UTILS/lua/promote'
local is_in   = require 'RSUTILS/lua/is_in'
local qcfg    = require 'Q/UTILS/lua/qcfg'

return function (
  operator, 
  f1, 
  f2,
  optargs
  )
  local subs = {}; 
  assert(type(operator) == "string")
  assert(type(f1) == "lVector"); assert(f1:has_nulls() == false)
  assert(type(f2) == "lVector"); assert(f2:has_nulls() == false)

  local f1_qtype = f1:qtype();   
  local f2_qtype = f2:qtype();   
  assert(is_in(f1_qtype, { "F4", "F8", }))
  assert(is_in(f2_qtype, { "F4", "F8", }))
  subs.max_num_in_chunk = f1:max_num_in_chunk()
  assert(f1:max_num_in_chunk() == f2:max_num_in_chunk())

  local f3_qtype
  if ( ( f1_qtype == "F4" ) and ( f2_qtype == "F4" ) ) then
    f3_qtype = "F4"
  else
    f3_qtype = "F8"
  end
  if ( optargs ) then
    assert(type(optargs) == "table")
    if ( optargs.f3_qtype ) then
      f3_qtype = optargs.f3_qtype
    end
  end
  assert(is_in(f3_qtype, { "F4", "F8", }))

  subs.fn = operator .. "_" .. f1_qtype .. "_" .. f2_qtype .. "_" .. f3_qtype 

  subs.f1_ctype = cutils.str_qtype_to_str_ctype(f1_qtype)
  subs.f1_cast_as = subs.f1_ctype .. "*"

  subs.f2_ctype = cutils.str_qtype_to_str_ctype(f2_qtype)
  subs.f2_cast_as = subs.f2_ctype .. "*"

  subs.f3_qtype = f3_qtype
  subs.f3_ctype = cutils.str_qtype_to_str_ctype(f3_qtype)
  subs.f3_cast_as = subs.f3_ctype .. "*"

  subs.f3_width = cutils.get_width_qtype(f3_qtype)
  subs.bufsz = subs.max_num_in_chunk * subs.f3_width

  --===============
  subs.cargs = nil
  subs.cst_cargs = ffi.NULL

  if ( f3_qtype == "F4" ) then 
    subs.code = "c = sqrtf(a*a + b*b); "
  else
    subs.code = "c = sqrt((double)a*(double)q + (double)b*(double)b); "
  end
  subs.tmpl   = "OPERATORS/F1F2OPF3/lua/f1f2opf3_sclr.tmpl"
  subs.incdir = "OPERATORS/F1F2OPF3/gen_inc/"
  subs.srcdir = "OPERATORS/F1F2OPF3/gen_src/"
  subs.incs = { "OPERATORS/F1F2OPF3/gen_inc/", }
  subs.libs = { "-lgomp", "-lm", } 
  subs.chunk_size = 1024 -- TODO P4 experiment
  subs.comment_ispc = "//" 
  return subs
end
