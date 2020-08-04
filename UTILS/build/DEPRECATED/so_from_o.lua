local cutils       = require 'libcutils'
local qconsts      = require 'Q/UTILS/lua/q_consts'
local chk_env_vars = require 'Q/UTILS/build/chk_env_vars'

local function so_from_o()
  local final_h, final_so, q_build_dir = chk_env_vars()
-- final_so is ... TODO P1
  local tgt_so = q_build_dir .. "/libq_core.so"
  local odir   = q_build_dir .. "/obj/"
  --===== Combine .o files into single .so file
  local lflags = qconsts.Q_LINK_FLAGS
  assert( ( type(lflags) == "string") and ( #lflags > 0 ) )
  
  --  "gcc %s %s -I %s %s -lgomp -pthread -shared -o %s", 
  local q_cmd = string.format(" gcc %s/*.o  %s -o %s", 
    odir, lflags, tgt_so)
  local status = os.execute(q_cmd)
  assert(status, q_cmd)
  assert(cutils.isfile(tgt_so), "Target " .. tgt_so .. " not created")
  print("Successfully created " .. tgt_so)
  cutils.copyfile(tgt_so, final_so)
  print("Copied " .. tgt_so .. " to " .. final_so)
  return true
end
return so_from_o
-- so_from_o()
