local cutils  = require 'libcutils'
local cVector = require 'libvctr'
local data_dir = cVector.data_dir()
local cmd = string.format("find %s -type f -delete", data_dir)
return function()
  os.execute(cmd)
-- TODO P4 add rmdir functionality to  cutils and use instead of os.exec
end
