local plpath = require 'pl.path'
local qconsts = require 'Q/UTILS/lua/q_consts'
local recursive_copy = require 'Q/UTILS/build/recursive_copy'
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
numc = recursive_copy("*.c", "/gen_src", rootdir, cdir)
--==========================
local hdir = build_dir .. "/include/"
if ( not plpath.isdir(hdir) ) then plpath.mkdir(hdir) end
numh = recursive_copy("*.h", "/gen_inc", rootdir, hdir)
--==========================
print("Copied " .. numc .. " .c files ")
print("Copied " .. numh .. " .h files ")
-- TODO P1 Should we do assert(numc == num) ?
