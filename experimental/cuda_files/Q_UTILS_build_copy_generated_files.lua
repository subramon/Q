local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
local plfile = require 'pl.file'
--=================================
function recursive_copy( file_pattern, dir_pattern, currdir, destdir )
  if string.find(currdir, dir_pattern)  then 
    print(currdir)
    local F = pldir.getfiles(currdir, file_pattern)
    assert(#F > 0, "No files like " .. file_pattern .. " in " .. currdir)
    for k, v in pairs(F) do
       plfile.copy(v, destdir)
     end
  end
  local D = pldir.getdirectories(currdir)
  for index, v in ipairs(D) do
    -- CUDA: Added below condition to copy the files with ".cu" extention to destdir for F1F2OPF3
    if v == "/home/krushna/WORK/Q/OPERATORS/F1F2OPF3/gen_src" then
      file_pattern = "*.cu"
    end
    recursive_copy(file_pattern, dir_pattern, v, destdir)
  end
end
--==========================
local rootdir = os.getenv("Q_SRC_ROOT")
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
assert(plpath.isdir(rootdir))
--==========================
local build_dir = os.getenv("Q_BUILD_DIR")
if ( not plpath.isdir(build_dir) ) then plpath.mkdir(build_dir) end
--==========================
local cdir = build_dir .. "/src/"
if ( not plpath.isdir(cdir) ) then plpath.mkdir(cdir) end
recursive_copy("*.c", "/gen_src", rootdir, cdir)
--==========================
local hdir = build_dir .. "/include/"
if ( not plpath.isdir(hdir) ) then plpath.mkdir(hdir) end
recursive_copy("*.h", "/gen_inc", rootdir, hdir)
--==========================
