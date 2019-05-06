local Q		= require 'Q'
local qc	= require 'Q/UTILS/lua/q_core'
local qconsts	= require 'Q/UTILS/lua/q_consts'

local function load_data(data_file_path, metadata_file_path)
  assert(type(data_file_path) == "string")
  assert(type(metadata_file_path) == "string")
  assert(qc.isfile(metadata_file_path), "ERROR: Please check metadata_file_path " .. metadata_file_path)
  assert(qc.isfile(data_file_path), "ERROR: Please check data_file")
  local optargs = { is_hdr = false, use_accelerator = true }
  local M = dofile(metadata_file_path)
  local status, ret = pcall(Q.load_csv, data_file_path, M, optargs)
  assert( status == true, "Error: " .. tostring(ret) .. "   : Loading Aborted ")
  print("Data load done !!")
  return ret
end

return load_data
