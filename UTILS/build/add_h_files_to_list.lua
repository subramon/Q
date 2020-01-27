local plpath = require 'pl.path'
local get_func_decl   = require 'Q/UTILS/build/get_func_decl'
local exec_and_capture_stdout=require 'Q/UTILS/lua/exec_and_capture_stdout'
local qconsts      = require 'Q/UTILS/lua/q_consts'

local struct_files = {
  "core_vec_struct.h",
  "scalar_struct.h",
  "spooky_struct.h",
  "cmem_struct.h",
  "const_struct.h", -- from OPERATORS/S_TO_F/
  "seq_struct.h", -- from OPERATORS/S_TO_F/
  "rand_struct.h", -- from OPERATORS/S_TO_F/
  "period_struct.h", -- from OPERATORS/S_TO_F/
}

local q_files =  { 
  "q_constants.h", 
  "q_macros.h", 
  "q_incs.h"  
}

local function add_h_files_to_list(
  h_files
  )
  assert(h_files and ( type(h_files) == "table" ) ) 

  local cleaned_defs = {}
  local hash_defines = {}
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
  -- add struct files first
  for _, file in ipairs(struct_files) do
    local full_file_name = qconsts.Q_BUILD_DIR .. "/include/" .. file
    if ( not plpath.isfile(full_file_name) ) then 
      print("Not adding struct file " .. file)
    else
      local cleaned_def, hash_define = get_func_decl(full_file_name)
      cleaned_defs[#cleaned_defs + 1] = cleaned_def
      hash_defines[#hash_defines + 1] = hash_define
    end
  end
  -- add other files, excluding some 
  for _, h_file in ipairs(h_files) do
    local full_file_name = qconsts.Q_BUILD_DIR .. "/include/" .. h_file
    if ( not x_files[full_file_name] ) then 
      local cleaned_def, hash_define = get_func_decl(full_file_name)
      cleaned_defs[#cleaned_defs + 1] = cleaned_def
      hash_defines[#hash_defines + 1] = hash_define
    end
  end
  -- add stuff from q_constants.h
  local full_file_name = qconsts.Q_BUILD_DIR .. "/include/q_constants.h"
  cmd = string.format("grep \"^#define\" %s | grep -v __ ", full_file_name)
  local  defines = exec_and_capture_stdout(cmd)
  hash_defines[#hash_defines + 1] = defines
  --=========================
  return cleaned_defs, hash_defines
end
return add_h_files_to_list
