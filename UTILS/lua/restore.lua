local cutils  = require 'libcutils'
-- TO DELETE local qc      = require 'Q/UTILS/lua/q_core'
local qconsts = require 'Q/UTILS/lua/q_consts'

local function restore(file_to_restore)
  local metadata_file
  if ( file_to_restore ) then 
    metadata_file = file_to_restore
  else
    metadata_file = qconsts.Q_METADATA_FILE
  end
  assert(type(metadata_file) == "string", "metadata file is not provided")
  assert(cutils.isfile(metadata_file), -- checking isfile present
    "Meta file not found = " .. metadata_file)
  local status, reason = pcall(dofile, metadata_file)
  return status, reason -- responsibility of caller
end
return require('Q/q_export').export('restore', restore)
