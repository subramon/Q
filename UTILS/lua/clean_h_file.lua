local function clean_h_file(h_file)
  -- INDRA: Can we delete below?
  -- local cmd = string.format([[cat %s | sed 's/\\n/\n/g'| grep -v '#include'| cpp | grep -v '^#']], h_file)
  local cmd = string.format(
  -- INDRA: Can remove the grep -v of include
  [[cat %s | grep -v '#include'| cpp | grep -v '^#']], h_file)
  local handle = assert(io.popen(cmd))
  local res = handle:read("*a")
  handle:close()
  assert(#res > 0)
  return res
end
return  clean_h_file
