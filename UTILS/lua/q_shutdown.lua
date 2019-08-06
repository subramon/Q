local qconsts = require 'Q/UTILS/lua/q_consts'

local function q_shutdown()
  local Q = require 'Q'
  -- Call save() functionality if Q_METADATA_FILE env variable defined
  local meta_file = qconsts.Q_METADATA_FILE
  if ( type(meta_file) == "string" ) then 
    Q.save()
  else
    print("Q server exiting without saving")
  end
  -- Add any other cleanup activities as they become necessary
  os.exit()
end
return require('Q/q_export').export('shutdown', q_shutdown)
