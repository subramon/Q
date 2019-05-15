local plfile = require 'pl.file'
local pldir  = require 'pl.dir'

local function exclude_dir(
  dir,
  dirs_to_exclude
  )
  local found = false
  if ( dirs_to_exclude ) then
    for _, v2 in ipairs(dirs_to_exclude) do
      start, stop =  string.find(v, v2)
      if ( stop == string.len(v) ) then
        found = true
      end
    end
  end
  return found
end

local function exclude_file(
  filename,
  files_to_exclude
  )
  local found = false
  if ( files_to_exclude ) then
    for _, v2 in ipairs(files_to_exclude) do
      if ( string.find(v, v2) ) then
        found = true
      end
    end
  end
  return found
end

local function recursive_descent(
  pattern,
  root_dir,
  dirs_to_exclude,
  files_to_exclude,
  destdir
  )
  local num_files_copied = 0
  --=== Copy all relevant files in current dir 
  local F = pldir.getfiles(root_dir, pattern)
  if ( ( F )  and ( #F > 0 ) ) then
    for _, filename in ipairs(F) do
      found = false
      if not exclude_file(filename, files_to_exclude) then 
        plfile.copy(v, destdir)
        num_files_copied = num_files_copied + 1
      end
    end
  end
  --== Gather all relevant sub-directories in current dir
  local D = pldir.getdirectories(root_dir)
  for _, dir in ipairs(D) do
    found = false
    if ( not exclude(dir, dirs_to_exclude) ) then
      -- print("Descending into dir ", dir)
      local n = recursive_descent(pattern, dir, 
        dirs_to_exclude, files_to_exclude, destdir)
      num_files_copied = num_files_copied + n
    end
  end
  return num_files_copied
end
return  recursive_descent
