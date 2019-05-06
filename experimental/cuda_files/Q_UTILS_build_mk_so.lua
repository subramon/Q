local q_root = os.getenv("Q_ROOT")
assert(q_root, "Do export Q_ROOT=/home/subramon/Q/ or some such")
final_h  = q_root .. "/include/"
final_so = q_root .. "/lib/"
local q_build_dir = assert(os.getenv("Q_BUILD_DIR"), "Requires to Q_BUILD_DIR to be specified")
-- local dbg = require 'Q/UTILS/lua.debugger'
local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
local plfile = require 'pl.file'
assert(plpath.isdir(q_build_dir), "Directory not found: " .. q_build_dir)
assert(plpath.isdir(final_h), "Directory not found: " .. final_h)
assert(plpath.isdir(final_so), "Directory not found: " .. final_so)

local function clean_defs(file)
   local cmd = string.format("cat %s | grep -v '#include'| cpp | grep -v '^#'", file)
   local handle = io.popen(cmd)
   local res = handle:read("*a")
   handle:close()
   return res
end

local function is_struct_file(file)
  assert(plpath.isfile(file), "Could not find file " .. file)
    if string.match(plfile.read(file), "struct ") then
        return true
    else
        return false
    end
    return nil
end

 local function add_h_files_to_list(list, file_list)
     for i=1,#file_list do
         list[#list + 1] = clean_defs(file_list[i])
     end
     return list
 end

local tgt_so = q_build_dir .. "/libq_core.so"
local tgt_h = q_build_dir .. "/q_core.h"
local hdir = q_build_dir .. "/include"
local cdir = q_build_dir .. "/src"

----------Create q_core.h
local q_struct_files = {}
local q_h = {}
local q_h_files = {}
local q_c_files = {}
local q_h_set = {} 
local h_files = pldir.getfiles(hdir, "*.h")
for num=1,#h_files do
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
local QC_FLAGS = assert(os.getenv("QC_FLAGS"), "QC_FLAGS not provided")
-- CUDA: Overridden QC_FLAGS to remove options which prints warning on console
local QC_FLAGS = "-g -Xcompiler -fPIC -Xcompiler -fopenmp "
local Q_LINK_FLAGS = assert(os.getenv("Q_LINK_FLAGS"), "Q_LINK_FLAGS not provided")
assert(QC_FLAGS ~= "", "QC_FLAGS not provided")
assert(Q_LINK_FLAGS ~= "", "Q_LINK_FLAGS not provided")
local q_c_files = pldir.getfiles(cdir, "*.c")
local q_c = table.concat(q_c_files, " ")

local q_cu_files = pldir.getfiles(cdir, "*.cu")
local q_cu = table.concat(q_cu_files, " ")
--  "gcc %s %s -I %s %s -lgomp -pthread -shared -o %s",
-- CUDA: Changed the compiler to nvcc instead of gcc because now we do have cuda files for compilation
-- CUDA: Also included c and cu files at the time of compilation
local q_cmd = string.format("nvcc %s %s -I %s %s -o %s", 
  QC_FLAGS, q_c .. " " .. q_cu, hdir, Q_LINK_FLAGS, tgt_so)
q_cmd = "cd " .. cdir .. "; " .. q_cmd
local status = os.execute(q_cmd)
assert(status, "nvcc failed")
assert(plpath.isfile(tgt_so), "Target " .. tgt_so .. " not created")
print("Successfully created " .. tgt_so)
pldir.copyfile(tgt_so, final_so)
print("Copied " .. tgt_so .. " to " .. final_so)
