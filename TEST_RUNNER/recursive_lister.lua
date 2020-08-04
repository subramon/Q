require 'Q/UTILS/lua/strict'
local pldir  = require 'pl.dir'
local plpath  = require 'pl.path'
--=== Following to prune unwanted file
local blacklist = require 'Q/TEST_RUNNER/blacklist'
local qconsts	= require 'Q/UTILS/lua/q_consts'
local q_src_root = qconsts.Q_SRC_ROOT

local ignore_files = {}
for i, v in pairs(blacklist) do
  local filename = plpath.abspath(q_src_root .. "/" ..  v)
  ignore_files[filename] = true
end

--=== Following to prune unwanted directories
local x_ignore_dirs = { "TODO", "DOC", "doc", "experimental", "DEPRECATED" } 
local ignore_dirs = {}
for k, v in ipairs(x_ignore_dirs) do
  ignore_dirs[v] = true
end
local function explore(dir)
  dir = plpath.basename(dir)
  if ( ignore_dirs[dir] ) then return false else return true end 
end
--=================================
local function recursive_lister( 
  T, -- list of files so far 
  dir
)
--[[
If current_directory is black-listed, return T
Else, find files that start with start_pattern and end with stop_pattern
and add them to T. Then, for each directory in this directory, call
recursive_lister
--]]
  local basename = plpath.basename(dir)
  if ( explore(dir) ) then 
    local files = pldir.getfiles(dir, "test_*.lua")
    for _, f in ipairs(files)  do
      f = plpath.abspath(f)
      if ( not ignore_files[f] ) then
        T[#T+1] = f
      end
    end
    local dirs = pldir.getdirectories(dir)
    for _, d in ipairs(dirs)  do
      recursive_lister(T, d)
    end
  end
end
return recursive_lister
--[[
local T = {}
recursive_lister(T, ".")
for _, v in ipairs(T) do print(v) end 
--]]
