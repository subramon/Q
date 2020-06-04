local cutils  = require 'libcutils'
local cVector = require 'libvctr'

local function reset()
  local data_dir = cVector.get_globals("data_dir") 
  assert(cutils.isdir(data_dir))
  local meta_file = data_dir .. "/q_meta.lua" -- note .lua suffix
  local aux_file  = data_dir .. "/q_aux" -- note *NO* .lua suffix 
  cutils.delete(meta_file)
  cutils.delete(aux_file)
  cVector.set_globals("max_file_num", 0)

  local cmd = string.format("rm -f %s/_*.bin", data_dir)
  os.execute(cmd) -- TODO P3 Move this to rmdir in cutils 
  return true
end
return require('Q/q_export').export('reset', reset)
