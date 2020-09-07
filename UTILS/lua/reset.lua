local cutils = require 'libcutils'
local qmem   = require 'Q/UTILS/lua/qmem'

local function reset()
  local data_dir = qmem.q_data_dir
  assert(cutils.isdir(data_dir))
  local meta_file = data_dir .. "/q_meta.lua" -- note .lua suffix
  local aux_file  = data_dir .. "/q_aux" -- note *NO* .lua suffix 
  cutils.delete(meta_file)
  cutils.delete(aux_file)
  -- TODO TODO P0 cVector.set_globals("max_file_num", 0)

  local cmd = string.format("rm -f %s/_*.bin", data_dir)
  os.execute(cmd) -- TODO P3 Move this to rmdir in cutils 
  return true
end
return require('Q/q_export').export('reset', reset)
