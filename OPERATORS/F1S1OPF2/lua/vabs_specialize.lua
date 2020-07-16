local cVector = require 'libvctr'
local qconsts       = require "Q/UTILS/lua/q_consts"
local get_ptr       = require "Q/UTILS/lua/get_ptr"
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
return function ( f1, sclrs, optargs)

  local f1_qtype = f1:qtype()
  assert(is_base_qtype(f1_qtype))
  local subs = {}; 
  subs.fn = "vabs_" .. f1_qtype 

  subs.f1_qtype   = f1_qtype
  subs.f1_ctype   = qconsts.qtypes[f1_qtype].ctype

  subs.f2_qtype   = subs.f1_qtype
  subs.f2_ctype   = subs.f1_ctype

  local f2_width  = qconsts.qtypes[subs.f2_qtype].width
  subs.f2_buf_sz  = cVector.chunk_size() * f2_width

  subs.cst_f1_as = subs.f1_ctype  .. "*" 
  subs.cst_f2_as = subs.f2_ctype .. "*" 

  local funcs = {
    I1 = "abs", 
    I2 = "abs", 
    I4 = "abs", 
    I8 = "llabs", 
    F4 = "fabsf", 
    F8 = "fabs"
  }
  local cast = {
    I1 = "(int8_t)", 
    I2 = "(int16_t)", 
    I4 = "(int32_t)", 
    I8 = "(int64_t)", 
    F4 = "(float)", 
    F8 = "(double)"
  }

  subs.c_code_for_operator = 
    "c = ".. cast[f1_qtype] .. funcs[f1_qtype] .."(a);"

  subs.srcdir  = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir  = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs    = { "OPERATORS/F1S1OPF2/gen_inc/", "UTILS/inc/" }
  subs.tmpl    = "OPERATORS/F1S1OPF2/lua/f1opf2.tmpl"
  return subs
end
