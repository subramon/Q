-- local dbg = require 'Q/UTILS/lua/debugger'

local function q_shutdown()
  local Q = require 'Q'
  -- Call the save() functionality depending upon Q_METADATA_FILE env variable
  local meta_file = os.getenv("Q_METADATA_FILE")
  if meta_file then
    Q.save()
  end
  -- Here is where we will add any other cleanup activities as they become necessary
  os.exit()
end
return require('Q/q_export').export('shutdown', q_shutdown)
