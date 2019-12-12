-- INDRA: Why not use get_func_decl from build/ and deprecate this?
--
local function clean_h_file(h_file)
  local cmd = string.format(
  [[cat %s | grep -v '#include'| cpp | grep -v '^#']], h_file)
  local handle = assert(io.popen(cmd))
  local res = handle:read("*a")
  handle:close()
  assert(#res > 0)
  return res
end
return  clean_h_file
