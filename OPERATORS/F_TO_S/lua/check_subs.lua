local function check_subs(subs)
  assert(type(subs.fn) == "string")
  assert(type(subs.in_ctype) == "string")
  assert(type(subs.comparator) == "string")
  assert(type(subs.alt_comparator) == "string")
  assert(type(subs.tmpl) == "string" )
  assert(type(subs.args_ctype) == "string")
  assert(subs.args)
  return true
end
return check_subs
