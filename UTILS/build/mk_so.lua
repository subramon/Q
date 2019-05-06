local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
local plfile = require 'pl.file'
local qconsts = require 'Q/UTILS/lua/q_consts'

-- START: Get and validate following environment variables
-- Q_ROOT
-- Q_BUILD_DIR
-- QC_FLAGS
-- Q_LINK_FLAGS
local q_root = qconsts.Q_ROOT
assert(q_root, "Do export Q_ROOT=/home/subramon/Q/ or some such")
final_h  = q_root .. "/include/"
final_so = q_root .. "/lib/"
local q_build_dir = qconsts.Q_BUILD_DIR
-- local dbg = require 'Q/UTILS/lua.debugger'
assert(plpath.isdir(q_build_dir), "Directory not found: " .. q_build_dir)
assert(plpath.isdir(final_h), "Directory not found: " .. final_h)
assert(plpath.isdir(final_so), "Directory not found: " .. final_so)

local QC_FLAGS = qconsts.QC_FLAGS
assert(QC_FLAGS ~= "", "QC_FLAGS not provided")

local Q_LINK_FLAGS = qconsts.Q_LINK_FLAGS
assert(Q_LINK_FLAGS ~= "", "Q_LINK_FLAGS not provided")
--
-- STOP: Get and validate needed environment variables

-- TODO P1: COMMENT: What does this function do?
local function clean_defs(file)
   local cmd = string.format("cat %s | grep -v '#include'| cpp | grep -v '^#'", file)
   local handle = io.popen(cmd)
   local res = handle:read("*a")
   handle:close()
   return res
end

-- Input: source file 
-- Output: true if the word "struct" occurs in the file, false otherwise
local function is_struct_file(file)
  assert(plpath.isfile(file), "Could not find file " .. file)
  if string.match(plfile.read(file), "struct ") then
    return true
  else
    return false
  end
end

 local function add_h_files_to_list(
   list, 
   file_list
   )
   assert(list)
   assert( file_list and ( type(file_list) == "table" ) ) 
   for i = 1, #file_list do
      list[#list + 1] = clean_defs(file_list[i])
   end
   return list
 end

local tgt_so = q_build_dir .. "/libq_core.so"
local tgt_h  = q_build_dir .. "/q_core.h"
local hdir   = q_build_dir .. "/include"
local cdir   = q_build_dir .. "/src"

----------Create q_core.h
local q_struct_files = {}
local q_h = {}
local q_h_files = {}
local q_c_files = {}
local q_h_set = {} 
local h_files = pldir.getfiles(hdir, "*.h")
for num = 1, #h_files do
  local file_path = h_files[num]
  if is_struct_file(file_path) then
    q_struct_files[#q_struct_files + 1] = file_path
  else
    q_h_files[#q_h_files + 1] = file_path
  end
  q_h_set[file_path] = true
end

q_h = add_h_files_to_list(q_h, q_struct_files)
q_h = add_h_files_to_list(q_h, q_h_files)
q_h = table.concat(q_h, "\n")
plfile.write(tgt_h, q_h)
pldir.copyfile(tgt_h, final_h)
print("Copied " .. tgt_h .. " to " .. final_h)

----------Create q_core.so

local q_c_files = pldir.getfiles(cdir, "*.c")
local q_c = table.concat(q_c_files, " ")
--  "gcc %s %s -I %s %s -lgomp -pthread -shared -o %s", 
local q_cmd = string.format("gcc %s %s -I %s %s -o %s", 
  QC_FLAGS, q_c, hdir, Q_LINK_FLAGS, tgt_so)
q_cmd = "cd " .. cdir .. "; " .. q_cmd
local status = os.execute(q_cmd)
assert(status, "gcc failed")
assert(plpath.isfile(tgt_so), "Target " .. tgt_so .. " not created")
print("Successfully created " .. tgt_so)
pldir.copyfile(tgt_so, final_so)
print("Copied " .. tgt_so .. " to " .. final_so)
