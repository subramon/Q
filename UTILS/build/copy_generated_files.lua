local qconsts = require 'Q/UTILS/lua/q_consts'

local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
local plfile = require 'pl.file'
--=================================
function recursive_copy( file_pattern, dir_pattern, currdir, destdir )
  -- look for files that match file_pattern in directories 
  -- (in the current directory) that match dir_pattern. 
  -- copy these files to the directory destdir 
  -- it is an error to find no files matching file_pattern in a 
  -- directory that matches dir_pattern
  if string.find(currdir, dir_pattern)  then 
    -- print(currdir)
    local F = pldir.getfiles(currdir, file_pattern)
    assert(#F > 0, "No files like " .. file_pattern .. " in " .. currdir)
    for k, v in pairs(F) do
       plfile.copy(v, destdir)
     end
  end
  local D = pldir.getdirectories(currdir)
  for index, v in ipairs(D) do
    recursive_copy(file_pattern, dir_pattern, v, destdir)
  end
end
--==========================
local rootdir = qconsts.Q_SRC_ROOT
assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
assert(plpath.isdir(rootdir))
--==========================
local build_dir = qconsts.Q_BUILD_DIR
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
