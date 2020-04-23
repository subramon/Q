local cutils         = require 'libcutils'
local qconsts        = require 'Q/UTILS/lua/q_consts'
local recursive_copy = require 'Q/UTILS/build/recursive_copy'

-- From all directories under root_dir that match "/gen_src/"
-- copy *.c files into cdir
-- From all directories under root_dir that match "/gen_inc/"
-- copy *.h files into hdir
local function copy_gen_files()
  local numc = 0 
  local numh = 0 
  --==========================
  local rootdir = qconsts.Q_SRC_ROOT
  assert(rootdir, "Do export Q_SRC_ROOT=/home/subramon/WORK/Q or some such")
  assert(cutils.isdir(rootdir))
  --==========================
  local build_dir = qconsts.Q_BUILD_DIR
  if ( not cutils.isdir(build_dir) ) then cutils.makepath(build_dir) end
  --==========================
  local cdir = build_dir .. "/src/"
  if ( not cutils.isdir(cdir) ) then cutils.makepath(cdir) end
  numc = recursive_copy("*.c", "/gen_src", rootdir, cdir)
  --==========================
  local hdir = build_dir .. "/include/"
  if ( not cutils.isdir(hdir) ) then cutils.makepath(hdir) end
  numh = recursive_copy("*.h", "/gen_inc", rootdir, hdir)
  --==========================
  print("Copied " .. numc .. " .c files ")
  print("Copied " .. numh .. " .h files ")
  -- TODO P1 Should we do assert(numc == numh) ?
  return numc, numh
end
return  copy_gen_files
-- copy_gen_files()
