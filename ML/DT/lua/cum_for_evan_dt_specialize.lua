local qconsts   = require 'Q/UTILS/lua/q_consts'
local is_in     = require 'Q/UTILS/lua/is_in'
local tmpl      = qconsts.Q_SRC_ROOT .. "/ML/DT/lua/cum_for_evan_dt.tmpl"
local valid_f_types = { "I1", "I2", "I4", "I8", "F4", "F8" }
local valid_g_types = { "I1", "I2", "I4", "I8", "F4", "F8" } 
return function (
  f_qtype,
  g_qtype
  )
  local subs = {}; 
  assert(is_in(f_qtype, valid_f_types))
  assert(is_in(g_qtype, valid_g_types))
  subs.fn = "cum_for_evan_dt_" .. f_qtype .. "_" .. g_qtype
  subs.f_ctype = qconsts.qtypes[f_qtype].ctype
  subs.g_ctype = qconsts.qtypes[g_qtype].ctype

  subs.tmpl = tmpl
  return subs
end
