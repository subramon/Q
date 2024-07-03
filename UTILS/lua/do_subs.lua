local cutils = require 'libcutils'
local function do_subs(tmpl_file, out_file, replacements)
  assert(cutils.isfile(tmpl_file), "File not found " .. tmpl_file)
  assert(type(replacements) == "table")
  local tmpl = cutils.read(tmpl_file)
  assert(#tmpl > 0)

  local out = tmpl
  for k, v in pairs(replacements) do 
    out = string.gsub(out, k, v)
  end
  cutils.write(out_file, out)
  assert(cutils.isfile(out_file), "file not created " .. out_file)
  return true
end
return do_subs
