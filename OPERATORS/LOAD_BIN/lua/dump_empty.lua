local cutils = require 'libcutils'
local function dump_empty(infiles, nnfiles, num_in_files)
  -- delete empty files if any
  local num_empty = 0
  for k = 1, #infiles do 
    if ( num_in_files[k] == 0 ) then 
      num_empty = num_empty + 1
    end
  end
  if ( num_empty == 0 ) then
    print("No empty files")
    return 
  end
  print("Original number of files = ", #infiles)
  print("Deleting empty files of which there are ", num_empty)
  local new_idx = 1
  local new_infiles = {}
  local new_nnfiles 
  if ( nnfiles ) then 
    new_nnfiles = {} 
  end
  --======================================================
  for k, infile in ipairs(infiles) do 
    if ( num_in_files[k] > 0 ) then 
      new_infiles[new_idx] = infiles[k]
      if ( nnfiles ) then 
        new_nnfiles[new_idx] = nnfiles[k]
      end
      new_idx = new_idx + 1 
    else
	print("Deleting empty file ", infiles[k])
    end
  end
  print("Reduced number of infiles = ", #new_infiles)
  if ( nnfiles ) then
    print("Reduced number of nnfiles = ", #new_nnfiles)
  end 
  local new_num_in_files = {}
  for k, new_infile in ipairs(new_infiles) do 
    new_num_in_files[k] = cutils.getsize(new_infile)
    assert(new_num_in_files[k] > 0)
  end
  return new_infiles, new_nnfiles, new_num_in_files
end
return dump_empty
