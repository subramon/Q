-- TODO P2 Replace these with C functions using a Lua/C binding like Scalar
-- This entire file should be deleted and replaced with cutils
--
local assertx = require 'Q/UTILS/lua/assertx'
local fileops = {}
local cutils = require 'libcutils'

local exists = function(name)
   local str = string.format("ls %s 2>/dev/null 1>/dev/null", name)
   local v = os.execute(str) 
	return v == 0
end
--[[ replaced by cutils
--- Check if a directory exists in this path
fileops.isdir = function(path)
  -- "/" works on both Unix and Windows
  return exists(path) and exists(path.."/")
end

fileops.isfile = function(path)
    return exists(path) and not exists(path.."/")
end

fileops.list_files_in_dir = function(path, regex)
  assertx(cutils.isdir(path), "Must be a dir ", path)
  local cmd_str = string.format("find %s -name '%s'", path, regex)
  local stream = io.popen(cmd_str)
   local c = {}
  while true do
    local e = stream:read()
    if e == nil then break end
    c[#c + 1] = e
  end
  stream:close()
  return c
end
--]]

fileops.read = function(path)
  local file = io.open(path, "r")
  assertx(file ~= nil, "Unable to open file", path)
  local contents = file:read("*a")
  file:close()
  return contents
end


return fileops
