local add_h_files_to_list = require 'Q/UTILS/build/add_h_files_to_list'
local is_struct_file       = require 'Q/UTILS/build/is_struct_file'
local chk_env_vars         = require 'Q/UTILS/build/chk_env_vars'
local pldir                = require 'pl.dir'
local plfile               = require 'pl.file'
local function mk_q_core_h()
-- final_h is where all the .h files that need to be cdef'd will be kept
  local final_h, _, q_build_dir = chk_env_vars()
  local tgt_h  = q_build_dir .. "/q_core.h"
  local hdir   = q_build_dir .. "/include/"
  local q_h = {} -- table of all .h files to be cocantenated

  -- We need to make sure that all structs get put in first
  -- hence the need to denote some files as struct files
  local q_struct_files = {} -- table of all .h files with typedef struct
  local q_h_files = {}      -- rest of the .h files

  local h_files = pldir.getfiles(hdir, "*.h")
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
  return true
end
return mk_q_core_h
-- mk_q_core_h()
