local cVector = require 'libvctr'
local qconsts = require 'Q/UTILS/lua/q_consts'
local is_in   = require 'Q/UTILS/lua/is_in'
local chk_inputs    = require 'Q/OPERATORS/F1S1OPF2/lua/chk_inputs'
return function (
  f1,
  sclrs,
  optargs
  )
  assert(chk_inputs(f1, sclrs, optargs))
  local f1_qtype = f1:qtype()

  assert(is_in(f1_qtype, {"B1", "I1", "I2", "I4", "I8"}))
  local subs = {}; 
  subs.fn = "vnot_" .. f1_qtype

  subs.f1_qtype = f1_qtype
  subs.f2_qtype = f1_qtype

  if ( f1_qtype == "B1" ) then 
    subs.f1_ctype = "uint64_t"
    subs.f2_ctype = "uint64_t"
  else
    subs.f1_ctype = "u" .. qconsts.qtypes[f1_qtype].ctype
    subs.f2_ctype = "u" .. qconsts.qtypes[subs.f2_qtype].ctype
 end 

  local f2_width  = qconsts.qtypes[subs.f2_qtype].width
  subs.f2_buf_sz  = cVector.chunk_size() * f2_width

  subs.cst_f1_as = subs.f1_ctype .. "*" 
  subs.cst_f2_as = subs.f2_ctype .. "*" 

  subs.tmpl   = "OPERATORS/F1S1OPF2/lua/vnot.tmpl"
  subs.srcdir = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs   = { "OPERATORS/F1S1OPF2/gen_inc/", "UTILS/inc/" }
  if ( f1_qtype == "B1" ) then 
    subs.tmpl = nil -- no code generation
    subs.dotc = "OPERATORS/F1S1OPF2/src/vnot_B1.c"
    subs.doth = "OPERATORS/F1S1OPF2/inc/vnot_B1.h"
    subs.srcs = { "UTILS/src/set_bit_u64.c", "UTILS/src/get_bit_u64.c" }
  end
  return subs
end

