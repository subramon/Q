local function o_from_c()
  
  --======= Create .o files from .c files
  ---------- Get list of all C files 
  local cdir   = q_build_dir .. "/src/"
  local q_c_files = pldir.getfiles(cdir, "*.c")
  assert(type(q_c_files) == "table")
  assert(#q_c_files > 0, "No C files found")
  
  local odir   = q_build_dir .. "/obj/"
  local cflags = qconsts.QC_FLAGS
  assert( ( type(cflags) == "string") and ( #cflags > 0 ) )
  
  if (plpath.isdir(odir)) then 
    pldir.rmtree(odir)
  end
  pldir.makepath(odir)
  assert(plpath.isdir(odir))
  for _, cfile in pairs(q_c_files) do 
    ofile = string.gsub(cfile, "/src/", "/obj/")
    ofile = string.gsub(ofile, "%.c", "%.o")
    local q_cmd = string.format("gcc -c %s %s -I %s -o %s", 
    cfile, cflags, hdir, ofile)
    local status = os.execute(q_cmd)
    assert(status, q_cmd)
  end
end
return o_from_c
