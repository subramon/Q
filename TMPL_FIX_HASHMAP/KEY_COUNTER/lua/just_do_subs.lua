local plfile = require 'pl.file'
local plpath = require 'pl.path'

local function just_do_subs(
  label,
  infile,
  outfile
  )
  assert(type(label) == "string")
  assert(#label > 0)

  assert(type(infile) == "string")
  assert(#infile > 0)
  plpath.exists(infile)

  assert(type(outfile) == "string")
  assert(#outfile > 0)
  assert(infile ~= outfile)
  plfile.delete(outfile)

  local x = plfile.read(infile)
  local from = "${tmpl}"
  local to   = label
  local y = string.gsub(x, from, to)
  plfile.write(outfile, y)

end
return just_do_subs
