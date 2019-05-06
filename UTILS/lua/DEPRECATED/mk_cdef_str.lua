function mk_cdef_str(dir)
  local extract_fn_proto = require 'Q/UTILS/lua/extract_fn_proto'
  local plpath = require 'pl.path'
  local plfile = require 'pl.file'
  local pldir  = require 'pl.dir'
  assert(plpath.isdir(dir), "Directory not found " .. dir)
  srcfiles  = pldir.getfiles(dir, "*.c")
  assert(#srcfiles > 0, "No files found")
  incs = {}
  for i, v in ipairs(srcfiles) do
    local x = extract_fn_proto(v)
    incs[#incs+1] = x
  end
  return table.concat(incs, "\n")
end

-- x = mk_cdef_str("../src/") print(x)
