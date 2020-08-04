local cutils        = require 'libcutils'
local qconsts       = require 'Q/UTILS/lua/q_consts'
local lib_prefix = qconsts.Q_ROOT .. "/lib/lib"
--================================================
local function is_so_file(fn)
  local is_so = false
  local sofile = lib_prefix .. fn .. ".so" -- to be created
  if ( cutils.isfile(sofile) ) then
    -- print("File exists: No need to create " .. sofile)
    is_so = true
  end
  return is_so, sofile
end
return is_so_file 
