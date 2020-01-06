local qconsts = require "Q/UTILS/lua/q_consts"
local data_dir = qconsts.Q_DATA_DIR
return function()
   os.execute(string.format("find %s -type f -delete", data_dir))
-- TODO P4 add rmdir functionality to  cutils and use instead of os.exec
end
