local add_h_files_to_list = require 'Q/UTILS/build/add_h_files_to_list'
local chk_env_vars        = require 'Q/UTILS/build/chk_env_vars'
local pldir               = require 'pl.dir'
local plfile              = require 'pl.file'
local function mk_q_core_h()
-- final_h is where all the .h files that need to be cdef'd will be kept
  local final_h, _, q_build_dir = chk_env_vars()
  local tgt_h  = q_build_dir .. "/q_core.h"
  local hdir   = q_build_dir .. "/include/"

  -- assemble all .h files  in table h_files
  local h_files = pldir.getfiles(hdir, "*.h")
  --[[
  local q_h_files = {}      
  for _, h_file in pairs(h_files) do 
    q_h_files[#q_h_files + 1] = h_file
  end
  --]]
  
  local cleaned_defs = add_h_files_to_list(h_files)
  cleaned_defs = table.concat(cleaned_defs, "\n")
  plfile.write(tgt_h, cleaned_defs)
  pldir.copyfile(tgt_h, final_h)
  print("Created and Copied " .. tgt_h .. " to " .. final_h)
  return true
end
return mk_q_core_h
-- mk_q_core_h()
