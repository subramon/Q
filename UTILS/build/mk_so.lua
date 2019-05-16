local plpath         = require 'pl.path'
local pldir          = require 'pl.dir'
local plfile         = require 'pl.file'
local qconsts        = require 'Q/UTILS/lua/q_consts'
local chk_env_vars   = require 'Q/UTILS/build/chk_env_vars'
local is_struct_file = require 'Q/UTILS/build/is_struct_file'
local add_h_files_to_list    = require 'Q/UTILS/build/add_h_files_to_list'

-- final_h is where all the .h files that need to be cdef'd will be kept
-- final_so is ... TODO P1
final_h, final_so, q_build_dir = chk_env_vars()

local tgt_so = q_build_dir .. "/libq_core.so"
local tgt_h  = q_build_dir .. "/q_core.h"
local hdir   = q_build_dir .. "/include/"

----------Create tgt_h = q_core.h
local q_struct_files = {}
local q_h = {}
local q_h_files = {}
local q_c_files = {}
local h_files = pldir.getfiles(hdir, "*.h")
-- We need to make sure that all structs get put in first
-- hence the need to denote some files as struct files
for _, h_file in pairs(h_files) do 

  if is_struct_file(h_file) then
    q_struct_files[#q_struct_files + 1] = h_file
  else
    q_h_files[#q_h_files + 1] = h_file
  end
end

q_h = add_h_files_to_list(q_h, q_struct_files)
q_h = add_h_files_to_list(q_h, q_h_files)
q_h = table.concat(q_h, "\n")
plfile.write(tgt_h, q_h)
pldir.copyfile(tgt_h, final_h)
print("Created and Copied " .. tgt_h .. " to " .. final_h)

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
--===== Combine .o files into single .so file
local lflags = qconsts.Q_LINK_FLAGS
assert( ( type(lflags) == "string") and ( #lflags > 0 ) )

local q_c = table.concat(q_c_files, " ")
--  "gcc %s %s -I %s %s -lgomp -pthread -shared -o %s", 
local q_cmd = string.format(" gcc %s/*.o  %s -o %s", 
  odir, lflags, tgt_so)
local status = os.execute(q_cmd)
assert(status, q_cmd)
assert(plpath.isfile(tgt_so), "Target " .. tgt_so .. " not created")
print("Successfully created " .. tgt_so)
pldir.copyfile(tgt_so, final_so)
print("Copied " .. tgt_so .. " to " .. final_so)
