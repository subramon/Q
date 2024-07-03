local cutils = require 'libcutils'
local function c_exec(cmd)
  assert(type(cmd) == "string")
  assert(#cmd > 0)
  local rslt = cutils.exec(cmd)
  return rslt 
  -- Whether command succeeded is not known, caller needs to figure it out 
end
return c_exec
