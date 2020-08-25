local cutils  = require 'libcutils'
local qmem    = require 'Q/UTILS/lua/qmem'
local cmd = string.format("find %s -type f -delete", qmem.data_dir)
return function()
  os.execute(cmd)
-- TODO P4 add rmdir functionality to  cutils and use instead of os.exec
end
