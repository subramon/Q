local qc            = require 'Q/UTILS/lua/q_core'
local function chk_file(infile)

  assert( (infile) and (qc.file_exists(infile)), err.INPUT_FILE_NOT_FOUND)
  assert(tonumber(qc.get_file_size(infile)) > 0, err.INPUT_FILE_EMPTY)
  return true
end
