local cutils = require 'libcutils'
local plpath = require 'pl.path'
local pldir  = require 'pl.dir'
local md5    = require 'md5'
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
  local num_files_skipped = 0
  assert( ( type(file_pattern) == "string") and ( #file_pattern > 0 ) )
  assert( ( type( dir_pattern) == "string") and ( #dir_pattern  > 0 ) )
  assert(plpath.isdir(currdir))
  assert(plpath.isdir(destdir))
  assert(currdir ~= destdir)
  if string.find(currdir, dir_pattern)  then 
    print("Searching in ", currdir)
    local files = pldir.getfiles(currdir, file_pattern)
    if  ( #files == 0 ) then
      print( "No files like " .. file_pattern .. " in " .. currdir)
    end
    for k, file in pairs(files) do
      local skip = false -- skip if old file == new file
      local oldfile = destdir .. string.gsub(file, "^.*/", "")
      if ( cutils.isfile(oldfile) ) then 
        local m1 = md5.sumhexa(file)
        local m2 = md5.sumhexa(oldfile)
        skip = true
        num_files_skipped = num_files_skipped + 1
      end
      if ( not skip ) then 
        cutils.copyfile(file, destdir)
        -- print("Copying " ..  file .. " to " ..  destdir)
        num_files_copied = num_files_copied + 1
      end
    end
  end
  local dirs = pldir.getdirectories(currdir)
  for _, dir in ipairs(dirs) do
    local n1, n2 = recursive_copy(file_pattern, dir_pattern, dir, destdir)
    num_files_copied  = num_files_copied  + n1
    num_files_skipped = num_files_skipped + n2
  end
  return num_files_copied, num_files_skipped
end
return recursive_copy
