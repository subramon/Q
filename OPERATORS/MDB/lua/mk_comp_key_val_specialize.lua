local qconsts = require 'Q/UTILS/lua/q_consts'
local tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/MDB/lua/mk_comp_key_val.tmpl.lua"
return function(in_qtype)
  local subs = {}
  subs.QTYPE = in_qtype
  subs.fn = "mk_comp_key_val_" .. in_qtype
  subs.VALTYPE = qconsts.qtypes[in_qtype].ctype
  subs.tmpl = tmpl
  return subs
end
