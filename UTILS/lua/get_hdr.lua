local function get_hdr(hfile)
  assert(io.input(hfile))
  local hdrs = io.read("*all")
  assert(#hdrs > 0)
  hdrs = string.gsub(hdrs, "#define.-\n", "")
  hdrs = string.gsub(hdrs, "#ifndef.-\n", "")
  hdrs = string.gsub(hdrs, "#endif.-\n", "")
  assert(#hdrs> 0)
  return hdrs
end
return get_hdr
-- print(get_hdr("../src/perturb_type.h"))
