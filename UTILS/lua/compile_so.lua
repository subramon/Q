return function (incs, srcs, tgt)
  local plpath = require 'pl.path'

  FLAGS = "-g -std=gnu99 -Wall -fPIC -W -Waggregate-return -Wcast-align -Wmissing-prototypes -Wnested-externs -Wshadow -Wwrite-strings -pedantic "

  assert(tgt, "Need a target")
  assert(srcs, "Need srcs ")
  assert(type(srcs) == "table")
  if ( incs ) then 
    assert(type(incs) == "table")
  end

  command = "gcc " .. FLAGS
  for i, v in ipairs(incs) do
    assert(plpath.isdir(incs[i]), "path not found " .. incs[i])
    incs[i] = "-I" .. incs[i] .. " "
  end
  command = command .. table.concat(incs)
  --================
  for i, v in ipairs(srcs) do
    assert(plpath.isfile(srcs[i]), "path not found " .. srcs[i])
    srcs[i] = " " .. srcs[i] .. " "
  end
  command = command .. table.concat(srcs)
  command = command .. " -shared -o " .. tgt
  print(command)
  status = os.execute(command)
  assert(status == 0,"command failed \n" .. command)
  return true
end
--[[ sample invocation
incs = { "../../../UTILS/inc/", "../../../UTILS/gen_inc/", "../gen_inc/"}
srcs = { "get_cell.c", "../../../UTILS/src/mmap.c" }
tgt = "libget_cell.so"
compile_so(incs, srcs, tgt)
--]]
