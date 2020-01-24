local function check_subs(subs)
  assert(type(subs) == "table")
  assert(type(subs.fn) == "string")
  assert(type(subs.len) == "number")
  assert(type(subs.out_qtype) == "string") 
  assert(type(subs.out_ctype) == "string") 
  assert(type(subs.tmpl) == "string") 
  assert(type(subs.args_ctype) == "string") 
  assert(subs.args)
  assert(type(subs.buf_size) == "number")
  return true
end
return check_subs
