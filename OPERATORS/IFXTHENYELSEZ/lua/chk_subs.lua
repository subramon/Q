local function chk_subs(subs)
  assert(type(subs.fn) == "string")
  assert(type(subs.ctype) == "string")
  assert(type(subs.wtype) == "string")
  assert(type(subs) == "table")
  return true
end
