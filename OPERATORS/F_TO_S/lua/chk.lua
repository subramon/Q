local qconsts = require 'Q/UTILS/lua/q_consts'
local tmpl = qconsts.Q_SRC_ROOT .. '/OPERATORS/F_TO_S/lua/reduce.tmpl'

function f_to_s_min_chk(
  intype
  )

  local subs = {}
  subs.fn = "min_" .. intype 
  subs.intype = qconsts.qtypes[intype].ctype
  subs.reducer = "mcr_sum"
  subs.tmpl = tmpl
  return subs
end
