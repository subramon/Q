local qconsts = require 'Q/UTILS/lua/q_consts'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')

return function(qtype, comparison, optargs)
  local tmpl
  local fast = false
  if ( optargs ) then 
    assert(type(optargs) == "table")
    if ( optargs.mode == "fast" ) then
      tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/lua/par_is_next.tmpl"
      fast = true
    end
  end
  if ( not tmpl ) then 
    tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/F_TO_S/lua/is_next.tmpl" 
  end
  local subs = {}
  assert(is_base_qtype(qtype))
  if ( comparison == "gt" ) then
    subs.comparison_operator = " <= " 
  elseif ( comparison == "lt" ) then
    subs.comparison_operator = " >= " 
  elseif ( comparison == "geq" ) then
    subs.comparison_operator = " < " 
  elseif ( comparison == "leq" ) then
    subs.comparison_operator = " > " 
  elseif ( comparison == "eq" ) then
    subs.comparison_operator = " == " 
  elseif ( comparison == "neq" ) then
    subs.comparison_operator = " != " 
  else
    assert(nil, "invalid comparison" .. comparison)
  end
  subs.qtype = qtype
  local rec_name = string.format("is_next_%s_%s_ARGS",
    comparison, qtype)
  if ( fast ) then rec_name = "par_" .. rec_name end
  subs.rec_name = rec_name
  subs.fast = fast
  subs.comparison = comparison
  subs.ctype = qconsts.qtypes[qtype].ctype
  if ( fast ) then 
    subs.fn = "par_is_next_" .. comparison .. "_" .. qtype
  else
    subs.fn = "is_next_" .. comparison .. "_" .. qtype
  end
  --==============================
  subs.tmpl = tmpl
  return subs
end
