local cutils  = require 'libcutils'
local cVector = require 'libvctr'

local function restore()
  local data_dir = cVector.get_globals("data_dir") 
  assert(cutils.isdir(data_dir))
  local meta_file = data_dir .. "/q_meta.lua" 
  local aux_file  = data_dir .. "/q_aux.lua" 

  if ( not cutils.isfile(meta_file) or ( not cutils.isfile(aux_file) ) ) then
    -- TODO P2: There should not be any .bin files
    local F = cutils.getfiles(data_dir, "*.bin")
    if ( #F > 0 ) then
      print("WARNING!!! There are bin files but no meta files")
    end
    local cmd = string.format("rm -f %s/_*.bin", data_dir)
    os.execute(cmd) -- TODO P3 Move this to rmdir in cutils 
    cutils.delete(aux_file)
    cutils.delete(meta_file)
    print("Nothing to restore")
    return true
  end

  local status, reason = pcall(dofile, meta_file)
  assert(status, reason)
  aux_file  = data_dir .. "/q_aux"  -- note we take out .lua suffix
  local T = require(aux_file)
  assert(type(T) == "table")
  local max_file_num = T.max_file_num
  assert(type(max_file_num) == "number")
  assert(cVector.set_globals("max_file_num", max_file_num))
  return true
end
return require('Q/q_export').export('restore', restore)
