local simple_do_subs = 
  require '/Q/TMPL_FIX_HASHMAP/KEY_COUNTER/lua/simple_do_subs'
local plfile = require 'pl.file'
local plpath = require 'pl.path'
local function copy_generic_code(
  label,
  root_indir,
  root_outdir,
  F
  )
  assert(type(label) == "string")
  assert(type(root_indir) == "string")
  assert(plpath.isdir(root_indir))
  assert(type(root_outdir) == "string")
  if ( not plpath.isdir(root_outdir)) then 
    assert(plpath.mkdir(root_outdir))
    print("making " .. root_outdir)
  end
  assert(plpath.isdir(root_outdir))
  assert(type(F) == "table")

  for _, suffix in ipairs({ ".c", ".h", }) do
    local indir, outdir
    if ( suffix == ".c" ) then 
      indir = root_indir .. "/src/"
      outdir = root_outdir .. "/src/"
    elseif ( suffix == ".h" ) then 
      indir = root_indir .. "/inc/"
      outdir = root_outdir .. "/inc/"
    else
      error("XXX")
    end
    -- make output directories if needed
    assert(plpath.isdir(indir))
    if ( not plpath.isdir(outdir)) then 
      assert(plpath.mkdir(outdir))
      print("making " .. outdir)
    end
  
    for i, f in pairs(F) do 
      local infile = indir .. "/rs_hmap_" .. f .. suffix
      assert(plpath.exists(infile))

      local outfile = outdir .. "/_rs_hmap_" .. f .. suffix
      simple_do_subs(label, infile, outfile)
      -- print(infile .. "  -> " .. outfile)
    end
  end
end
return copy_generic_code
