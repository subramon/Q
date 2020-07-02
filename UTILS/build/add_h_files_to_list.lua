local plpath = require 'pl.path'
local get_func_decl   = require 'Q/UTILS/build/get_func_decl'
local exec_and_capture_stdout=require 'Q/UTILS/lua/exec_and_capture_stdout'
local qconsts      = require 'Q/UTILS/lua/q_consts'
local struct_files = require 'Q/UTILS/build/struct_files'

local function add_h_files_to_list(
  h_files
  )
  assert(type(h_files) == "table" )
  local S0, S1, S2 = struct_files()
  local cleaned_defs = {}
  local hash_defines = {}
  -- assemble files to be excluded in x_files. These are 
  -- (1) struct files (2) UTILS/inc/q_*.h as shown below
  local x_files = {}
  for _, fname in pairs(S2) do 
    x_files[fname] = true 
  end
  -- NOTE: Do not treat following as struct files, even though
  -- it may appear tempting to do so.
  local q_files = { "q_constants.h", "q_macros.h", "q_incs.h",}
  for _, fname in pairs(q_files) do 
    local full_file_name = qconsts.Q_BUILD_DIR .. "/include/" .. fname
    x_files[full_file_name] = true 
  end
  --==============================================
  -- add struct files first
  for _, fname in ipairs(S2) do
    local cleaned_def, hash_define = get_func_decl(fname)
    cleaned_defs[#cleaned_defs + 1] = cleaned_def
    hash_defines[#hash_defines + 1] = hash_define
  end
  -- add other files, excluding struct files 
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
