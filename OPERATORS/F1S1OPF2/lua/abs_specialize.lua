local qconsts = require 'Q/UTILS/lua/q_consts'
local is_in   = require 'Q/UTILS/lua/is_in'
local tmpl    = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1S1OPF2/lua/f1opf2.tmpl"
local ok_qtypes = { "I1", "I2", "I4", "I8", "F4", "F8" }
return function (
  in_qtype
  )
  assert(is_in(in_qtype, ok_qtypes))
  
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
  local subs = {}; 
  subs.fn        = "abs_" .. in_qtype 
  subs.in_ctype  = qconsts.qtypes[in_qtype].ctype
  subs.in_qtype  = in_qtype
  subs.out_qtype = in_qtype
  subs.out_ctype = qconsts.qtypes[subs.out_qtype].ctype
  subs.tmpl      = tmpl
  subs.c_code_for_operator = "c = ".. cast[in_qtype] .. funcs[in_qtype] .."(a);"
  return subs
end
