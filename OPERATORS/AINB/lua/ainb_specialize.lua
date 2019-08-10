local qconsts = require 'Q/UTILS/lua/q_consts'
local is_base_qtype = require('Q/UTILS/lua/is_base_qtype')
return function (
  a_qtype,
  b_qtype,
  b_len,
  b_sort_order
  )
  local subs = {}; local tmpl
  assert(is_base_qtype(a_qtype), "type of A must be base type")
  assert(is_base_qtype(b_qtype), "type of B must be base type")
  if ( b_len <= 16 ) then 
    subs.fn = "simple_ainb_" .. a_qtype .. "_" .. b_qtype
    tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/AINB/lua/simple_ainb.tmpl"
  else 
    assert( b_sort_order == "asc", "B needs to be sorted ascending")
    subs.fn = "bin_search_ainb_" .. a_qtype .. "_" .. b_qtype
    tmpl = qconsts.Q_SRC_ROOT .. "/OPERATORS/AINB/lua/bin_search_ainb.tmpl"
  end
  subs.a_qtype = a_qtype
  subs.b_qtype = b_qtype
  subs.a_ctype = qconsts.qtypes[a_qtype].ctype
  subs.b_ctype = qconsts.qtypes[b_qtype].ctype
  subs.b_qtype = b_qtype
  subs.tmpl = tmpl
  return subs
end
