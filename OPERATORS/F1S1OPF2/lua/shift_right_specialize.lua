local qconsts        = require "Q/UTILS/lua/q_consts"
local Scalar         = require 'libsclr'
local to_scalar      = require 'Q/UTILS/lua/to_scalar'
local chk_shift_args = require 'Q/OPERATORS/F1S1OPF2/lua/chk_shift_args'
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F1S1OPF2/lua/shift.tmpl"
return function (
  qtype,
  scalar
  )

  local sval = assert(chk_shift_args(qtype, scalar))

  local lscalar = to_scalar(sval, "I4")

  local subs = {}; 
  local ctype = assert(qconsts.qtypes[qtype].ctype)
  subs.fn = "shift_right_" .. qtype 

  subs.in_ctype = ctype
  subs.in_qtype = qtype

  subs.out_qtype    = qtype
  subs.out_ctype    = ctype
  
  subs.c_code_for_operator = "c = a >> b;"
  subs.args        = lscalar:to_cmem()
  subs.args_ctype  = "int32_t "
  subs.cast_in_as = "u" .. subs.in_ctype -- note difference with shift left
  subs.scalar_ctype = "int32_t "
  subs.tmpl         = tmpl
  return subs
end
