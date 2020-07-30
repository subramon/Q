local plfile = require 'pl.file'
local plpath = require 'pl.path'
local function do_subs(tmpl_file, out_file, replacements)
  assert(plpath.isfile(tmpl_file))
  assert(type(replacements) == "table")
  local tmpl = plfile.read(tmpl_file)
  assert(#tmpl > 0)

  local out = tmpl
  for k, v in pairs(replacements) do 
    out = string.gsub(out, k, v)
  end
  plfile.write(out, out_file)
  assert(plpath.isfile(out_file))
end
return do_subs
