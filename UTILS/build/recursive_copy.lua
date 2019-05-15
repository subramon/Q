local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
local plfile = require 'pl.file'
--=================================
local function recursive_copy( 
  file_pattern, 
  dir_pattern, 
  currdir, 
  destdir 
)
--[[
look for files that match file_pattern in directories 
(in the current directory) that match dir_pattern. 
copy these files to the directory destdir 
it is an error to find no files matching file_pattern in a 
directory that matches dir_pattern
  --]]
  local num_files_copied = 0
  assert( ( type(file_pattern) == "string") and ( #file_pattern > 0 ) )
  assert( ( type( dir_pattern) == "string") and ( #dir_pattern  > 0 ) )
  assert(plpath.isdir(currdir))
  assert(plpath.isdir(destdir))
  assert(currdir ~= destdir)
  if string.find(currdir, dir_pattern)  then 
    -- print(currdir)
    local F = pldir.getfiles(currdir, file_pattern)
    assert(#F > 0, "No files like " .. file_pattern .. " in " .. currdir)
    for k, v in pairs(F) do
       plfile.copy(v, destdir)
       num_files_copied = num_files_copied + 1
     end
  end
  local D = pldir.getdirectories(currdir)
  for index, v in ipairs(D) do
    local n = recursive_copy(file_pattern, dir_pattern, v, destdir)
    num_files_copied  = num_files_copied + n
  end
  return num_files_copied
end
return recursive_copy
