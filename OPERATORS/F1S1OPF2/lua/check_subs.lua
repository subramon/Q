local function check_subs(subs)
  assert(type(subs.fn) == "string")
  assert(type(subs.tmpl) == "string")
  assert(type(subs.in_qtype)  == "string")
  assert(type(subs.out_qtype) == "string")
  assert(type(subs.in_ctype)  == "string")
  assert(type(subs.out_ctype) == "string")
  assert(type(subs.c_code_for_operator) == "string")
  -- TODO 
  assert(type(subs.reduce_qtype) == "string")
  assert(type(subs.in_ctype) == "string")
  if ( subs.tmpl ) then 
    assert(type(subs.tmpl) == "string" )
  else
    assert(type(subs.dotc) == "string" )
    assert(type(subs.doth) == "string" )
  end
  assert(type(subs.args_ctype) == "string")
  assert(type(subs.args) == "cdata")
  assert(subs.operator)
  if ( subs.operator == "sum" ) then 
    assert(type(subs.reduce_ctype) == "string")
  elseif ( ( subs.operator == "min" ) or ( subs.operator == "max" ) ) then
    assert(type(subs.comparator) == "string")
    assert(type(subs.alt_comparator) == "string")
  else
    error("")
  end
  --]]
  return true
end
return check_subs
