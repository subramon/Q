local cutils     = require 'libcutils'
local qcfg       = require 'Q/UTILS/lua/qcfg'
local lib_prefix = qcfg.q_root .. "/csos/lib"
--================================================
-- For example, if we need a function "foo", then we expect
-- that ${qcfg.qroot}/csos/libfoo.so to exist
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
