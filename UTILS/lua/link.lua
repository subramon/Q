local cutils        = require 'libcutils'
local qcfg = require 'Q/UTILS/lua/qcfg'
--================================================
local function link(
  dotos,  -- INPUT
  libs_c,  -- INPUT, any libraries that need to be linked
  libs_ispc,  -- INPUT, any libraries that need to be linked
  sofile -- to be created
  )
  --===============================
  local str_libs_c = ""
  if ( libs_c ) then
    str_libs_c = table.concat(libs_c, " ")
  end
  local str_libs_ispc = ""
  if ( libs_ispc ) then
    str_libs_ispc = table.concat(libs_ispc, " ")
  end
  local str_libs = str_libs_c .. str_libs_ispc
  -- handle case when ISPC is not being used 
  if ( qcfg.use_ispc ) then 
    str_libs = str_libs .. str_libs_ispc
  end 
  --===============================
  local str_dotos = table.concat(dotos, " ")
  --===============================
  local q_cmd = string.format("gcc -shared %s %s -o %s 1>/dev/null 2>&1",
       str_dotos, str_libs, sofile)
  print("linking ", q_cmd)
  local status = os.execute(q_cmd)
  assert(status == 0)
  assert(cutils.isfile(sofile))
  return true
end
return link
