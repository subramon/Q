local cutils        = require 'libcutils'
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
  --===============================
  local str_dotos = table.concat(dotos, " ")
  --===============================
  local q_cmd = string.format("gcc -shared %s %s -o %s",
       str_dotos, str_libs, sofile)
  local status = os.execute(q_cmd)
  assert(status == 0)
  assert(cutils.isfile(sofile))
  return true
end
return link
