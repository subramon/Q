local clean_defs   = require 'Q/UTILS/build/clean_defs'
local qconsts      = require 'Q/UTILS/lua/q_consts'

local struct_files = {
  "core_vec_struct.h",
  "scalar_struct.h",
  "spooky_struct.h",
  "cmem_struct.h",
}

local q_files =  { 
  "q_constants.h", 
  "q_macros.h", 
  "q_incs.h"  
}

local function add_h_files_to_list(
  h_files
  )
  local cleaned_defs = {}
  -- assemble files to be excluded in x_files
  local x_files = {}
  for k, file in pairs(struct_files) do 
    local full_file_name = qconsts.Q_BUILD_DIR .. "/include/" .. file
    x_files[full_file_name] = true 
  end
  for k, file in pairs(q_files) do 
    local full_file_name = qconsts.Q_BUILD_DIR .. "/include/" .. file
    x_files[full_file_name] = true 
  end
  --===============
  assert(h_files and ( type(h_files) == "table" ) ) 
  -- add struct files first
  for _, file in ipairs(struct_files) do
    local full_file_name = qconsts.Q_BUILD_DIR .. "/include/" .. file
    cleaned_defs[#cleaned_defs + 1] = clean_defs(full_file_name)
  end
  -- add other files, excluding some 
  for _, h_file in ipairs(h_files) do
    if ( not x_files[h_file] ) then 
      cleaned_defs[#cleaned_defs + 1] = clean_defs(h_file)
    end
  end
  return cleaned_defs
end
return add_h_files_to_list
