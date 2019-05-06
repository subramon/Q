local plfile = require "pl.file"
local pldir = require "pl.dir"
local plpath = require "pl.path"
local log = require "log"
local function get_files_from_metadata_file(file_path)
   -- assuming each line is an entry
   local used_files, v_pos, c_pos = {}, nil, nil
   for line in io.lines(file_path) do 
      v_pos = string.find(line, "Vector{")
      c_pos = string.find(line, "Column{")
      if v_pos and c_pos then error("How is there a column and a vector in entry " .. line) end
      if v_pos or c_pos then
         _, _, used_files[#used_files + 1]  = string.find(line, "filename='([^']-)'")
      end
   end
   return used_files
end

return function(meta_data_name)
   local f_name = string.format("%s/%s", os.getenv("Q_METADATA_DIR"), meta_data_name)
   assert(plpath.isfile(f_name), "Invalid meta data file " .. f_name)
   local used_files_list = get_files_from_metadata_file(f_name)
   local used_table = {}
   for _, v in ipairs(used_files_list) do
      if not plpath.isfile(v) then 
         log.warn(string.format("Missing file: %s", v))
      end
      used_table[v] = 1
   end
   local files_in_dir = pldir.getfiles(require('Q/q_export').Q_DATA_DIR) 
   local orphaned_files = {}
   for _, file in ipairs(files_in_dir) do
      if used_table[file] == nil then
         orphaned_files[#orphaned_files + 1] = file
         log.warn(string.format("Orphaned file: %s", file))
      end
   end
   return orphaned_files
end
