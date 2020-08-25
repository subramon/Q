local function add_trailing_slash(x)
  assert(type(x) == "string")
  assert(#x > 1)
  if ( string.sub(x, #x, #x) ~= "/" ) then
    x = x .. "/"
  end
  return x
end
return  add_trailing_slash
