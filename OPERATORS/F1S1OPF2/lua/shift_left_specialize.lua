local qconsts        = require "Q/UTILS/lua/q_consts"
local Scalar         = require 'libsclr'
local to_scalar      = require 'Q/UTILS/lua/to_scalar'
local chk_shift_args = require 'Q/OPERATORS/F1S1OPF2/lua/chk_shift_args'
return function (
  qtype,
  scalar
  )

  local status, sval = pcall(chk_shift_args, qtype, scalar)
  if ( not status ) then return "ok" end 

  local lscalar = to_scalar(sval, "I4")

  local subs = {}; 
  local ctype = assert(qconsts.qtypes[qtype].ctype)
  subs.fn = "shift_left_" .. qtype 

  subs.in_ctype = ctype
  subs.in_qtype = qtype

  subs.out_qtype    = qtype
  subs.out_ctype    = ctype

  subs.c_code_for_operator = "c = a << b;"
  subs.args        = lscalar:to_cmem()
  subs.args_ctype  = "int32_t "

  subs.cast_in_as   = subs.in_ctype -- not same for shift righ
  subs.scalar_ctype = "int32_t "
  subs.tmpl         = "OPERATORS/F1S1OPF2/lua/shift.tmpl"
  subs.srcdir       = "OPERATORS/F1S1OPF2/gen_src/"
  subs.incdir       = "OPERATORS/F1S1OPF2/gen_inc/"
  return subs
end
