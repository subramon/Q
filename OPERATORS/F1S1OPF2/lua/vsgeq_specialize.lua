local cVector = require 'libvctr'
local Scalar = require 'libsclr'
local chk_inputs    = require 'Q/OPERATORS/F1S1OPF2/lua/chk_inputs'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'
local to_scalar     = require 'Q/UTILS/lua/to_scalar'
local get_ptr       = require 'Q/UTILS/lua/get_ptr'

return function (
  f1,
  sclrs,
  optargs
  )
  local subs = {}; 
  chk_inputs(f1, sclrs, optargs)
  local scalar = sclrs 

  local f1_qtype = f1:qtype()
  assert(is_base_qtype(f1_qtype))

  scalar    = assert(to_scalar(scalar, f1_qtype))

  subs.fn = "vsgeq_" .. f1_qtype 

  subs.f1_qtype = f1_qtype
  subs.f1_ctype = qconsts.qtypes[subs.f1_qtype].ctype

  subs.f2_qtype = "B1"
  subs.f2_ctype = "uint64_t"

  subs.cst_f1_as = subs.f1_ctype  .. "*" 
  subs.cst_f2_as = subs.f2_ctype .. "*" 

  subs.args = get_ptr(scalar:to_cmem(), subs.cst_f1_as)

  local f2_width  = qconsts.qtypes[subs.f2_qtype].width
  subs.f2_buf_sz  = cVector.chunk_size() * f2_width

  subs.comparison = '  >=   '
  subs.tmpl = "OPERATORS/F1S1OPF2/lua/f1s1opf2_cmp.tmpl"
  subs.srcdir      = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1S1OPF2/gen_inc/", "UTILS/inc/" }
  subs.srcs        = { "UTILS/src/set_bit_u64.c" }
  return subs
end
