local do_subs = require 'do_subs'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
local extract_func_decl = require 'extract_func_decl'
local function copy_specific_code(
  label,
  prefix,
  indir,
  outdir,
  F
  )
  assert(type(label) == "string")
  assert(type(prefix) == "string")

  assert(type(indir) == "string")
  assert(plpath.isdir(indir))

  assert(type(outdir) == "string")
  assert(plpath.isdir(outdir))

  assert(type(F) == "table")
  assert(#F > 0)

  for i, f in ipairs(F) do 
    --==== create the .c file 
    local infile = indir .. "/" .. prefix .. f .. ".c"
    assert(plpath.exists(infile), "File not found " .. infile)

    local outfile = outdir .. "/src/_" .. prefix .. f .. ".c"
    do_subs(label, infile, outfile)
    -- print(infile .. "  -> " .. outfile)
    --==== create the .h file 
    assert(extract_func_decl(infile, outdir .. "/inc/"))
  end
end
return copy_specific_code
