local cutils = require 'libcutils'
local lgutils = require 'liblgutils'
local mysplit = require 'Q/UTILS/lua/mysplit'

local T = {}

local function import(tbsp_name, new_meta_dir, new_data_dir)
  assert(type(tbsp_name) == "string")
  assert(#tbsp_name > 0)

  assert(type(new_meta_dir) == "string")
  assert(type(new_data_dir) == "string")
  assert(new_meta_dir ~= new_data_dir)
  assert(cutils.isdir(new_meta_dir))
  assert(cutils.isdir(new_data_dir))

  local tbsp = lgutils.import_tbsp(tbsp_name, new_meta_dir, new_data_dir)
  assert(type(tbsp) == "number")

  -- Before we  execute the meta file, we make a copy of it 
  -- and modify it to include the tbsp 
  -- so instead of <<uqid = n>>, we have <<tbsp=m, uqid = n>>
  local orig_meta_file = new_meta_dir .. "/q_meta.lua"
  assert(cutils.isfile(orig_meta_file))
  local x = cutils.mkstemp("/tmp/q_meta_XXXXXX") 
  cutils.unlink(x)
  local temp_meta_file = x .. ".lua"
  local fpr = io.open(orig_meta_file, "r")
  local fpw = io.open(temp_meta_file, "w")
  local inlines = fpr:lines()
  local replace = "{ tbsp = " .. tostring(tbsp)  .. ", uqid = " 
  for inline in inlines do 
    -- print("inline = [[",  inline .. " ]] ")
    local outline = string.gsub(inline, "{ uqid = ", replace)
    fpw:write(outline .. "\n")
  end
  fpr:close()
  fpw:close()

  -- to execute the modified meta file, we need to set the Lua path 
  -- to include the /tmp/ directory where the temp_meta_file is 
  -- Notice that /tmp/ comes as the first entry in the LUA_PATH
  local oldpath = os.getenv("LUA_PATH")
  local T = mysplit(oldpath, ";")
  local newpath = "/tmp/?.lua;" .. table.concat(T, ";") .. ";;"
  package.path = newpath
  -- delete the prefix directory and .lua suffix 
  local bak_temp_meta_file = temp_meta_file
  temp_meta_file = string.gsub(temp_meta_file, "/tmp/", "")
  temp_meta_file = string.gsub(temp_meta_file, ".lua", "")
  require(temp_meta_file)
  cutils.unlink(bak_temp_meta_file)
  -- reset the lua path to what it was 
  package.path = oldpath

end
T.import = import
require('Q/q_export').export('import', import)
return T
