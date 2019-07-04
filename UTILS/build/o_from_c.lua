local chk_env_vars = require 'Q/UTILS/build/chk_env_vars'
local qconsts      = require 'Q/UTILS/lua/q_consts'
local plfile = require 'pl.file'
local pldir  = require 'pl.dir'
local plpath = require 'pl.path'

--======= Create .o files from .c files
local function o_from_c(
  only_new
  )
  _, _, q_build_dir = chk_env_vars()
  local cdir   = q_build_dir .. "/src/"
  local hdir   = q_build_dir .. "/include/"

  assert(type(only_new) == "boolean")
  
  ---------- Get list of all C files 
  local q_c_files = pldir.getfiles(cdir, "*.c")
  assert(type(q_c_files) == "table")
  assert(#q_c_files > 0, "No C files found")
  print("Initial number of C files ", #q_c_files)
  --=== If required, restrict to .c files more recent than their .o files.
  if ( only_new ) then 
    local T = {}
    for i, cfile in pairs(q_c_files) do
      ofile = string.gsub(cfile, "/src/", "/obj/")
      ofile = string.gsub(ofile, "%.c", "%.o")
      if ( plpath.isfile(ofile) ) then 
        otime = plfile.creation_time(ofile) 
        ctime = plfile.creation_time(cfile) 
        if ( ctime > otime ) then 
          T[#T+1] = cfile
          -- print("XX Stale  " ..  i .. " " .. ofile)
        else
          -- print("XX Fresh  " ..  i .. " " .. ofile)
        end
      else
        T[#T+1] = cfile
        -- print("XX Missing " ..  i .. " " .. ofile)
      end
    end
    q_c_files = T
  end
  print("Final number of C files ", #q_c_files)
  
  -- Determine directory for .o files
  local odir   = q_build_dir .. "/obj/"
  if ( not plpath.isdir(odir)) then 
    pldir.makepath(odir)
  end
  assert(plpath.isdir(odir))
  --================================
  local cflags = qconsts.QC_FLAGS
  assert( ( type(cflags) == "string") and ( #cflags > 0 ) )
  
  for _, cfile in pairs(q_c_files) do 
    ofile = string.gsub(cfile, "/src/", "/obj/")
    ofile = string.gsub(ofile, "%.c", "%.o")
    local q_cmd = string.format("gcc -c %s %s -I %s -o %s", 
    cfile, cflags, hdir, ofile)
    local status = os.execute(q_cmd)
    assert(status, q_cmd)
  end
  return true
end
return o_from_c
-- o_from_c(true)
-- print("ALL DONE")
