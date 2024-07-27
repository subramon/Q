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
  assert(tbsp > 0)

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
  local from_str = "tbsp = 0"
  local to_str   = " tbsp = " .. tostring(tbsp) 
  for inline in inlines do 
    -- print("inline = [[",  inline .. " ]] ")
    local outline = string.gsub(inline, from_str, to_str)
    fpw:write(outline .. "\n")
  end
  fpr:close()
  fpw:close()
  --== Load the modified meta file 
  print("Loading file " .. temp_meta_file)
  local x = loadfile(temp_meta_file)
  assert(type(x) == "function")
  x()
  -- TODO P0 cutils.unlink(temp_meta_file) --- no longer needed 
  -- reset the lua path to what it was 

end
T.import = import
require('Q/q_export').export('import', import)
return T
