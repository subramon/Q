local plfile = require 'pl.file'
local pldir  = require 'pl.dir'
local struct_files = require 'struct_files'

local function is_struct_file(
  infile
  )
  local found = false
  assert(type(struct_files) == "table")
  for _, struct_file in ipairs(struct_files) do
    start, stop =  string.find(infile, struct_file)
    if ( stop == string.len(infile) ) then
      found = true
    end
  end
  return found
end
return is_struct_file
