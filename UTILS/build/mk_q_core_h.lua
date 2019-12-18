local add_h_files_to_list = require 'Q/UTILS/build/add_h_files_to_list'
local chk_env_vars        = require 'Q/UTILS/build/chk_env_vars'
local cutils              = require 'libcutils'
local function mk_q_core_h()
-- final_h is where all the .h files that need to be cdef'd will be kept
  local final_h, _, q_build_dir = chk_env_vars()
  local tgt_h  = q_build_dir .. "/q_core.h"
  local tmp_h  = q_build_dir .. "/tmp_q_core.h"
  local hdir   = q_build_dir .. "/include/"

  -- assemble all .h files  in table h_files
  local h_files = cutils.getfiles(hdir, ".*.h$")
  assert(#h_files > 0)
  --[[
  local q_h_files = {}      
  for _, h_file in pairs(h_files) do 
    q_h_files[#q_h_files + 1] = h_file
  end
  --]]
  
  local cleaned_defs, hash_defines = add_h_files_to_list(h_files)
  assert(type(cleaned_defs) == "table")
  assert(type(hash_defines) == "table")
  cleaned_defs = table.concat(cleaned_defs, "\n")
  hash_defines = table.concat(hash_defines,  "\n")
  --[[
  print("== START cleaned_defs")
  print(cleaned_defs)
  print("== STOP  cleaned_defs")
  print("== START hash_defines")
  print(hash_defines)
  print("== STOP  hash_defines")
  --]]
  cutils.write(tmp_h, hash_defines .. cleaned_defs)
  assert(cutils.isfile(tmp_h))
  cmd = string.format("cpp %s > %s ", tmp_h, tgt_h)
  assert(os.execute(cmd))
  assert(cutils.isfile(tgt_h))
  assert(cutils.delete(tmp_h))
  cutils.copyfile(tgt_h, final_h)
  print("Created and Copied " .. tgt_h .. " to " .. final_h)
  return true
end
return mk_q_core_h
-- mk_q_core_h()
