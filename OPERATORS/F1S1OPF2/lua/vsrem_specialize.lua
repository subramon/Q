local cVector = require 'libvctr'
local qconsts       = require "Q/UTILS/lua/q_consts"
local get_ptr       = require "Q/UTILS/lua/get_ptr"
local chk_inputs    = require 'Q/OPERATORS/F1S1OPF2/lua/chk_inputs'
local qc            = require "Q/UTILS/lua/q_core"
local is_base_qtype = require 'Q/UTILS/lua/is_base_qtype'

return function (
  f1,
  sclrs,
  optargs
  )
  assert(chk_inputs(f1, sclrs, optargs))
  -- operator specific checking
  assert(type(sclrs) == "Scalar")
  local scalar = sclrs

  local f1_qtype = f1:qtype()
  assert(is_base_qtype(f1_qtype))
  local subs = {}; 
  subs.fn = "vsrem_" .. f1_qtype 

  subs.f1_qtype   = f1_qtype
  subs.f1_ctype   = assert(qconsts.qtypes[f1_qtype].ctype)

  subs.f2_qtype   = subs.f1_qtype
  subs.f2_ctype   = subs.f1_ctype

  local f2_width  = qconsts.qtypes[subs.f2_qtype].width
  subs.f2_buf_sz  = cVector.chunk_size() * f2_width

  subs.cst_f1_as = subs.f1_ctype  .. "*" 
  subs.cst_f2_as = subs.f2_ctype .. "*" 

  scalar = assert(scalar:conv(f1_qtype))
  subs.cargs        = scalar:to_cmem()
  subs.cst_cargs_as = subs.cst_f1_as

  subs.c_code_for_operator = "c = a % b;;"
  subs.tmpl        = "OPERATORS/F1S1OPF2/lua/arith.tmpl"
  subs.srcdir      = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir      = "OPERATORS/F1S1OPF2/gen_inc/"
  subs.incs        = { "OPERATORS/F1S1OPF2/gen_inc/", "UTILS/inc/" }
  return subs
end
