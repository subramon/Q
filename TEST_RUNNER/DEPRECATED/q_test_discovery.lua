local pldir     = require 'pl.dir'
local plpath    = require 'pl.path'
local blacklist = require 'Q/TEST_RUNNER/blacklist'
local qconsts	= require 'Q/UTILS/lua/q_consts'

local q_src_root = qconsts.Q_SRC_ROOT

local ignore_files = {}
for i, v in pairs(blacklist) do
  local filename = q_src_root .. "/" ..  v
  ignore_files[filename] = true
end

local ignore_dirs = {
  DEPRECATED = true,
  experimental = true,
  DOC = true,
  doc = true,
}

local function is_dir_exception(d)
  assert(type(d) == "string")
  local sd = string.match(d, "[^/]*$")
  print(d, sd) -- TODO DELETE LATER 
  return ignore_dirs[sd] == true or ignore_dirs[d] == true
end

local function is_file_exception(f)
  assert(type(f) == "string")
  local sf = string.match(f, "[^/]*$")
  return ignore_files[sf] == true or ignore_files[f] == true
end

local function exclude_non_test_files(files)
  -- Given a list of files, return only those files that
  -- start with the start_pattern and end with the stop_pattern
  local xfiles = {}
  start_pattern = "test_"
  stop_pattern  = ".lua"
  for _, full_name in ipairs(files) do
    local is_excl = false
    local base_name = plpath.basename(full_name)
    start, stop = string.find(base_name, start_pattern)
    if ( ( start == nil ) or ( start ~= 1 ) ) then
      is_excl = true
    end
    start, stop = string.find(base_name, stop_pattern)
    if ( stop == nil ) or ( stop ~= string.len(base_name) ) then
      is_excl = true
    end
    if ( not is_excl ) then
      xfiles[#xfiles+1] = full_name
    end
  end
  return xfiles
end

local function append_dirs(dest, src)
  for i=1,#src do
    if not is_dir_exception(src[i]) then
      dest[#dest + 1] = src[i]
    end
  end
  return dest
end

local function find_test_files(directory,  tests_pattern)
  -- convert 'directory' path to absolute path so that blacklisting feature will work
  directory = plpath.abspath(directory)
  local iter_list, next_iter_list = {}, {}
  local pattern = "*.lua" -- removed as args as *.lua is embedded in other parts of the code
  iter_list[1] = directory
  local list = {}
  repeat
    for i=1,#iter_list do
      local dir = iter_list[i]
      local exclude = false
      if ( ( string.find(dir, "[.]git") ) or
        ( string.find(dir, "DEPRECATED") ) ) then
        exclude = true
      end
      if ( not exclude ) then
        local files = pldir.getfiles(dir, pattern)
        local xfiles = exclude_non_test_files(files)
        local dirs = pldir.getdirectories(dir)
        next_iter_list = append_dirs(next_iter_list, dirs)
        for j=1,#xfiles do
          local xfile = xfiles[j]
          if not is_file_exception(xfile) then
            -- print("SCHEDULED ",file)
            list[#list + 1] = tostring(xfile)
          end
        end
      end
    end

    iter_list = next_iter_list
    next_iter_list = {}
  until #iter_list == 0
  return list
end

return find_test_files
