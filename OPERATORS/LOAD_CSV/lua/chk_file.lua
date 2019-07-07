local qc            = require 'Q/UTILS/lua/q_core'
local function chk_file(infile)
  assert( type(infile) == "string")
  assert(qc.file_exists(infile))
  assert(tonumber(qc.get_file_size(infile)) > 0)
  return true
end
return chk_file
