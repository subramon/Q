local cutils  = require 'libcutils'
local function chk_file(infile)
  assert( type(infile) == "string")
  assert(cutils.isfile(infile))
  assert(tonumber(cutils.getsize(infile)) > 0)
  return true
end
return chk_file
